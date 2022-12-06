//
//  OpenPassManager.swift
//  OpenPass
//
//  Created by Brad Leege on 10/11/22.
//

import AuthenticationServices
import Foundation
import Security

/// Primary app interface for integrating with OpenPass SDK

@available(iOS 13.0, *)
@MainActor
public final class OpenPassManager: NSObject {
    
    /// Singleton access point for OpenPassManager
    public static let main = OpenPassManager()
    
    /// Current AuthenticationTokens data
    public private(set) var authenticationTokens: AuthenticationTokens?
    
    private var openPassClient: OpenPassClient?
    
    /// OpenPass Web site for Authentication
    /// Override default by setting `OpenPassAuthenticationURL` in app's Info.plist
    private var authURL: String?
    
    private let defaultAuthURL = "https://auth.myopenpass.com/"
    
    /// OpenPass API server
    /// Override default by setting `OpenPassAuthenticationAPIURL` in app's Info.plist
    private var authAPIUrl: String?
    
    private let defaultAuthAPIUrl = "https://auth.myopenpass.com/"
    
    /// OpenPass Client Identifier
    /// Set `OpenPassClientId` in app's Info.plist
    private var clientId: String?
    
    /// OpenPass Client Redirect Uri
    private var redirectUri: String? {
        guard let redirectScheme = redirectScheme else { return nil }
        return redirectScheme + "://com.myopenpass.devapp"
    }
    
    /// Client specific redirect scheme
    private var redirectScheme: String?
    
    private override init() {
        
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "OpenPassClientId") as? String, !clientId.isEmpty else {
            return
        }
        self.clientId = clientId

        self.authURL = defaultAuthURL
        if let authURLOverride = Bundle.main.object(forInfoDictionaryKey: "OpenPassAuthenticationURL") as? String, !authURLOverride.isEmpty {
            self.authURL = authURLOverride
        }
        
        self.authAPIUrl = defaultAuthURL
        if let authAPIUrlOveride = Bundle.main.object(forInfoDictionaryKey: "OpenPassAuthenticationAPIURL") as? String, !authAPIUrlOveride.isEmpty {
            self.authAPIUrl = authAPIUrlOveride
        }

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
        
        self.openPassClient = OpenPassClient(authAPIUrl: authAPIUrl ?? defaultAuthAPIUrl)
        
    }
    
    /// Display the Authentication UX
    public func beginSignInUXFlow() async throws -> AuthenticationTokens {
        
        guard let authURL = authURL,
              let clientId = clientId,
              let redirectUri = redirectUri else {
            throw OpenPassError.missingConfiguration
        }
        
        let codeVerifier = randomString(length: 32)
        let challengeHashString = generateCodeChallengeFromVerifierCode(verifier: codeVerifier)
        
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
        
        guard let url = components?.url, let redirectScheme = redirectScheme else {
            throw OpenPassError.authorizationUrl
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectScheme) { callBackURL, error in
                
                if let error = error {
                
                    // Did User Cancel?
                    if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                        continuation.resume(throwing: OpenPassError.authorizationCancelled)
                        return
                    }
                    
                    // Other error?
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let queryItems = URLComponents(string: callBackURL?.absoluteString ?? "")?.queryItems, !queryItems.isEmpty else {
                    continuation.resume(throwing: OpenPassError.authorizationCallBackDataItems)
                    return
                }

                if let error = queryItems.filter({ $0.name == "error" }).first?.value,
                   let errorDescription = queryItems.filter({ $0.name == "error_description" }).first?.value {
                    continuation.resume(throwing: OpenPassError.authorizationError(code: error, description: errorDescription))
                    return
                }

                if let code = queryItems.filter({ $0.name == "code" }).first?.value,
                   let state = queryItems.filter({ $0.name == "state" }).first?.value,
                   let openPassClient = self?.openPassClient {

                    Task {
                        do {
                            let oidcToken = try await openPassClient.getTokenFromAuthCode(clientId: clientId,
                                                                                          code: code,
                                                                                          codeVerifier: codeVerifier,
                                                                                          redirectUri: redirectUri)
                            
                            let uid2Token = try await openPassClient.generateUID2Token(accessToken: oidcToken.accessToken)
                                
                            let authState = AuthenticationTokens(authorizeCode: code,
                                                                authorizeState: state,
                                                                oidcToken: oidcToken,
                                                                uid2Token: uid2Token)
                                
                            self?.setAuthenticationTokens(authState)
                            continuation.resume(returning: authState)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }

                    return
                }

                // Fallback
                continuation.resume(throwing: OpenPassError.authorizationCallBackDataItems)
                return
            }
            
            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = self
            session.start()
        }
    }
    
    /// Loads the current AuthenticationTokens (if one exists) into memory for app access
    public func loadAuthenticationTokens() -> AuthenticationTokens? {
        self.authenticationTokens = KeychainManager.main.getAuthenticationTokensFromKeychain()
        return self.authenticationTokens
    }
    
    /// Resets AuthenticationTokens within the SDK
    public func clearAuthenticationTokens() -> Bool {
        if KeychainManager.main.deleteAuthenticationTokensFromKeychain() {
            self.authenticationTokens = nil
            return true
        }
        return false
    }
    
    /// Utility function for persisting AuthenticationTokens data after its been loaded from the API Server
    private func setAuthenticationTokens(_ authenticationTokens: AuthenticationTokens) {
        if KeychainManager.main.saveAuthenticationTokensToKeychain(authenticationTokens) {
            self.authenticationTokens = authenticationTokens
        }
    }
    
    /// Creates a pseudo-random string containing basic characters using Array.randomElement()
    /// - Parameter length: Desired string length
    /// - Returns: Random string
    private func randomString(length: Int) -> String {
        var buffer = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64URLEncodedString()
    }
    
}
