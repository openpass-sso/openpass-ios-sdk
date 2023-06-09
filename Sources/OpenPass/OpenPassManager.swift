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
@available(iOS 13.0, tvOS 16.0, *)
@MainActor
public final class OpenPassManager: NSObject {
    
    /// Singleton access point for OpenPassManager
    public static let shared = OpenPassManager()
    
    /// Currently signed-in Open Pass user data
    public private(set) var openPassTokens: OpenPassTokens?
    
    private var openPassClient: OpenPassClient?
    
    /// OpenPass Server URL for Web UX and API Server
    /// Override default by setting `OpenPassBaseURL` in app's Info.plist
    private var baseURL: String?
    
    private let defaultBaseURL = "https://auth.myopenpass.com/"
        
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
    private let sdkName = "openpass-ios-sdk"
    
    /// The SDK version
    public let sdkVersion = "0.2.0"
    
    /// Keys and Values that need to be included in every network request
    private let baseRequestParameters: BaseRequestParameters
    
    /// Singleton Constructor
    private override init() {
        
        baseRequestParameters = BaseRequestParameters(sdkName: sdkName, sdkVersion: sdkVersion)
        
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "OpenPassClientId") as? String, !clientId.isEmpty else {
            return
        }
        self.clientId = clientId

        if let baseURLOverride = Bundle.main.object(forInfoDictionaryKey: "OpenPassBaseURL") as? String, !baseURLOverride.isEmpty {
            self.baseURL = baseURLOverride
        } else {
            self.baseURL = defaultBaseURL
        }
        
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for urlTypeDictionary in urlTypes {
                guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
                guard let externalURLScheme = urlSchemes.first else { continue }
                self.redirectScheme = externalURLScheme
                break
            }
        }
        
        self.openPassClient = OpenPassClient(baseURL: baseURL ?? defaultBaseURL, baseRequestParameters: baseRequestParameters)
        
        // Check for cached signin
        self.openPassTokens = KeychainManager.main.getOpenPassTokensFromKeychain()
    }
    

    /// Starts the OpenID Connect (OAuth) Authentication User Interface Flow
    /// - Returns: Authenticated ``OpenPassTokens``
    @discardableResult
    public func beginSignInUXFlow() async throws -> OpenPassTokens {
        
        guard let baseURL = baseURL,
              let clientId = clientId,
              let redirectUri = redirectUri else {
            throw OpenPassError.missingConfiguration
        }
        
        let codeVerifier = randomString(length: 32)
        let challengeHashString = generateCodeChallengeFromVerifierCode(verifier: codeVerifier)
        
        var components = URLComponents(string: baseURL)
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
        components?.queryItems?.append(contentsOf: baseRequestParameters.asQueryItems)
        
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
            
            #if os(iOS)
                session.prefersEphemeralWebBrowserSession = false
                session.presentationContextProvider = self
            #endif
            session.start()
        }
    }
    
    /// Signs user out by clearing all sign-in data currently in SDK.  This includes keychain and in-memory data
    /// - Returns: True if signed out, False if still sgined in
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
