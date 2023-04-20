//
//  OpenPassManager.swift
//
// MIT License
//
// Copyright (c) 2022 The Trade Desk (https://www.thetradedesk.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import AuthenticationServices
import Foundation
import Security

/// Primary app interface for integrating with OpenPass SDK

@available(iOS 13.0, *)
@MainActor
public final class OpenPassManager: NSObject {
    
    /// Singleton access point for OpenPassManager
    public static let shared = OpenPassManager()
    
    /// Current signed-in Open Pass user data
    public private(set) var openPassTokens: OpenPassTokens?
    
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
    
    /// The SDK name. This is being send to the API via HTTP headers to track metrics.
    public let sdkName: String
    
    /// The SDK version. This is being send to the API via HTTP headers to track metrics.
    public let sdkVersion: String
    
    /// Singleton Constructor
    private override init() {

        // SDK Supplied Properties
        let properties = SDKPropertyLoader.load()
        if let sdkName = properties.sdkName {
            self.sdkName = sdkName
        } else {
            self.sdkName = "openpass-ios-sdk"
        }
        
        if let sdkVersion = properties.sdkVersion {
            self.sdkVersion = sdkVersion
        } else {
            self.sdkVersion = "unknown"
        }
        
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
        
        self.openPassClient = OpenPassClient(authAPIUrl: authAPIUrl ?? defaultAuthAPIUrl, sdkVersion: sdkVersion)
        
        // Check for cached signin
        self.openPassTokens = KeychainManager.main.getOpenPassTokensFromKeychain()
    }
    
    /// Display the sign-in UX
    @discardableResult
    public func beginSignInUXFlow() async throws -> OpenPassTokens {
        
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
            URLQueryItem(name: "code_challenge", value: challengeHashString),
            URLQueryItem(name: "sdk_name", value: sdkName),
            URLQueryItem(name: "sdk_version", value: sdkVersion)
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
                   !code.isEmpty,
                   !state.isEmpty,
                   let openPassClient = self?.openPassClient {

                    Task {
                        do {
                            let openPassTokens = try await openPassClient.getTokenFromAuthCode(clientId: clientId,
                                                                                          code: code,
                                                                                          codeVerifier: codeVerifier,
                                                                                          redirectUri: redirectUri)
                            
                            let verified = try await openPassClient.verifyIDToken(openPassTokens)

                            if !verified {
                                continuation.resume(throwing: OpenPassError.verificationFailedForOIDCToken)
                                return
                            }
                                
                            self?.setOpenPassTokens(openPassTokens)
                            continuation.resume(returning: openPassTokens)
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
    
    /// Signs user out by clearing all sign-in data currently in SDK.  This includes keychain and in-memory data
    public func signOut() -> Bool {
        if KeychainManager.main.deleteOpenPassTokensFromKeychain() {
            self.openPassTokens = nil
            return true
        }
        return false
    }
        
    /// Utility function for persisting OpenPassTokens data after its been loaded from the API Server
    private func setOpenPassTokens(_ openPassTokens: OpenPassTokens) {
        if KeychainManager.main.saveOpenPassTokensToKeychain(openPassTokens) {
            self.openPassTokens = openPassTokens
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
