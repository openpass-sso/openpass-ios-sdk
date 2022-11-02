//
//  OpenPassManager.swift
//  OpenPass
//
//  Created by Brad Leege on 10/11/22.
//

import AuthenticationServices
import CryptoKit
import Foundation

@available(iOS 13.0, *)
public final class OpenPassManager: NSObject {
    
    /// Singleton access point for OpenPassManager
    public static let main = OpenPassManager()
    
    /// OpenPass Web site for Authentication
    private var authURL: String?
    
    /// OpenPass Client Identifier
    private var clientId: String?
    
    /// OpenPass Client Redirect Uri
    private var redirectUri: String? {
        guard let redirectScheme = redirectScheme else { return nil }
        return redirectScheme + "://com.myopenpass.devapp"
    }
    
    /// Client specific redirect scheme
    private var redirectScheme: String?
    
    private override init() {
        
        guard let authURL = Bundle.main.object(forInfoDictionaryKey: "OpenPassAuthenticationURL") as? String,
              let clientId = Bundle.main.object(forInfoDictionaryKey: "OpenPassClientId") as? String else {
            return
        }
        self.authURL = authURL
        self.clientId = clientId

        // TODO: - Use more secure client id based protocol for URL Scheme when OpenPass supports it (Ex: com.myopenpass.<UniqueClientNumber>://com.myopenpass.devapp)
        // TODO: - See https://atlassian.thetradedesk.com/jira/browse/OPENPASS-328
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for urlTypeDictionary in urlTypes {
                guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
                guard let externalURLScheme = urlSchemes.first else { continue }
                self.redirectScheme = externalURLScheme
                break
            }
        }

    }
    
    public func beginSignInUXFlow(completionHandler: @escaping (Result<[String: String], Error>) -> Void) {
        
        guard let authURL = authURL,
              let clientId = clientId,
              let redirectUri = redirectUri else {
            completionHandler(.failure(MissingConfigurationDataError()))
            return
        }
        
        let challengeData = Data(randomString(length: 32).utf8)
        let challengeHash = SHA256.hash(data: challengeData)
        let challengeHashString = challengeHash.compactMap { String(format: "%02x", $0) }.joined()
        
        var components = URLComponents(string: authURL)
        components?.path = "/v1/api/authorize"
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: "openid"),
            URLQueryItem(name: "state", value: randomString(length: 32)),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challengeHashString)
        ]
        print("url from components = \(String(describing: components?.string))")
        
        guard let url = components?.url else {
            completionHandler(.failure(AuthorizationURLError()))
            return
        }
                
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectScheme) { callBackURL, error in

            if let error = error {
                
                // Did User Cancel?
                if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                    completionHandler(.failure(AuthorizationCancelledError()))
                    return
                }
                
                // Other error?
                completionHandler(.failure(error))
                return
            }
                        
            guard let queryItems = URLComponents(string: callBackURL?.absoluteString ?? "")?.queryItems, !queryItems.isEmpty else {
                completionHandler(.failure(AuthorizationCallBackDataItemsError()))
                return
            }

            if let error = queryItems.filter({ $0.name == "error" }).first?.value,
               let errorDescription = queryItems.filter({ $0.name == "error_description" }).first?.value {
                completionHandler(.failure(AuthorizationError(error, errorDescription)))
                return
            }
            
            if let code = queryItems.filter({ $0.name == "status_code" }).first?.value,
               let state = queryItems.filter({ $0.name == "state" }).first?.value {
                completionHandler(.success(["code": code, "state": state]))
                return
            }

            // Fallback
            completionHandler(.failure(AuthorizationCallBackDataItemsError()))
        }
        
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = self
        session.start()
    }
    
    /// Creates a pseudo-random string containing basic characters using Array.randomElement()
    /// - Parameter length: Desired string length
    /// - Returns: Random string
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
    
}
