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
    private var redirectUri: String?
    
    private override init() {
        
        guard let authURL = Bundle.main.object(forInfoDictionaryKey: "OpenPassAuthenticationURL") as? String,
              let clientId = Bundle.main.object(forInfoDictionaryKey: "OpenPassClientId") as? String,
              let base64ClientId = clientId.data(using: .utf8)?.base64EncodedString() else {
            return
        }
        self.authURL = authURL
        self.clientId = clientId

        // TODO: - Use more secure client id system for URL Schemes when OpenPass supports it
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for urlTypeDictionary in urlTypes {
                guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
                guard let externalURLScheme = urlSchemes.first(where: { $0.contains(base64ClientId) }) else { continue }
                self.redirectUri = externalURLScheme
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
        
        let openPassURLScheme = String(redirectUri.split(separator: ":").first ?? "openpass")
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: openPassURLScheme) { callBackURL, error in

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
            
            guard let queryItems = URLComponents(string: callBackURL?.absoluteString ?? "")?.queryItems,
                  !queryItems.isEmpty,
                  let code = queryItems.filter({ $0.name == "code" }).first?.value,
                  let state = queryItems.filter({ $0.name == "state" }).first?.value else {
                completionHandler(.failure(AuthorizationCallBackDataItemsError()))
                return
            }

            completionHandler(.success(["code": code, "state": state]))
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
