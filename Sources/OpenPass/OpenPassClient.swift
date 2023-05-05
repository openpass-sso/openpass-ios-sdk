//
//  OpenPassClient.swift
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

import CryptoKit
import Foundation

/// Networking layer for OpenPass API Server

@available(iOS 13.0, *)
internal final class OpenPassClient {
    
    private let baseURL: String
    private let session: NetworkSession
    private let baseRequestParameters: [String: String]
    
    /// Set a specific leeway window in seconds in which the Expires At ("exp") Claim will still be valid.
    private var verifyExpiresAtLeeway: Int64 = 0
    
    /// Set a specific leeway window in seconds in which the Issued At ("iat") Claim will still be valid. This method
    /// overrides the value set with acceptLeeway(long). By default, the Issued At claim is always verified
    /// when the value is present
    private var verifyIssuedAtLeeway: Int64 = 1
    
    init(baseURL: String, sdkName: String, sdkVersion: String, _ session: NetworkSession = URLSession.shared) {
        self.baseURL = baseURL

        baseRequestParameters = [
            "OpenPass-SDK-Name": sdkName,
            "OpenPass-SDK-Version": sdkVersion
        ]

        self.session = session
    }
    
    func getTokenFromAuthCode(clientId: String,
                              code: String,
                              codeVerifier: String,
                              redirectUri: String) async throws -> OpenPassTokens {
        
        var components = URLComponents(string: baseURL)
        components?.path = "/v1/api/token"
        
        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw OpenPassError.urlGeneration
        }
        
        components?.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "code_verifier", value: codeVerifier)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        for (key, value) in baseRequestParameters {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = components?.query?.data(using: .utf8)
        
        let data = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let tokenResponse = try decoder.decode(OpenPassTokensResponse.self, from: data)
        
        if let tokenError = tokenResponse.error, !tokenError.isEmpty {
            throw OpenPassError.tokenData(name: tokenError,
                                          description: tokenResponse.errorDescription,
                                          uri: tokenResponse.errorUri)
        }
        
        guard let openPassTokens = tokenResponse.toOpenPassTokens() else {
            throw OpenPassError.tokenData(name: "OpenPassToken Generator",
                                          description: "Unable to generate OpenPassTokens from server",
                                          uri: nil)
        }
        
        return openPassTokens
    }
        
    /// Verifies IDToken
    ///  https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
    /// - Parameter openPassTokens: OpenPassTokens To Verify
    /// - Returns: True if valid, False if invalid
    func verifyIDToken(_ openPassTokens: OpenPassTokens) async throws -> Bool {
        
        guard let idToken = openPassTokens.idToken else {
            return false
        }
        
        // Expiration Check
        let now = Int64(Date().timeIntervalSince1970)
        let expiresPlusLeeway = idToken.expirationTime + (verifyExpiresAtLeeway * 1000)
        if now >= expiresPlusLeeway {
            return false
        }
        
        // Issued At Check
        let issuedAtPlusLeeway = idToken.issuedTime + (verifyIssuedAtLeeway * 1000)
        if !(now >= idToken.issuedTime && now <= issuedAtPlusLeeway) {
            return false
        }
        
        // Get JWKS
        var components = URLComponents(string: baseURL)
        components?.path = "/.well-known/jwks"
        
        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw OpenPassError.urlGeneration
        }
        
        var request = URLRequest(url: url)
        for (key, value) in baseRequestParameters {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = "GET"
        
        let jwksData = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let jwksResponse = try decoder.decode(JWKS.self, from: jwksData)
                
        // Look for matching Keys between JWTS and JWK
        guard let jwk = jwksResponse.keys.first(where: { openPassTokens.idToken?.keyId == $0.keyId }) else {
            throw OpenPassError.invalidJWKS
        }
        
        return jwk.verify(openPassTokens.idTokenJWT)
    }
    
}
