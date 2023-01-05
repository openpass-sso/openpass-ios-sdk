//
//  OpenPassClient.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import CryptoKit
import Foundation

/// Networking layer for OpenPass API Server

@available(iOS 13.0, *)
final class OpenPassClient {
    
    private let authAPIUrl: String
    private let session: NetworkSession
    
    init(authAPIUrl: String, _ session: NetworkSession = URLSession.shared) {
        self.authAPIUrl = authAPIUrl
        self.session = session
    }
    
    func getTokenFromAuthCode(clientId: String, code: String, codeVerifier: String, redirectUri: String) async throws -> OpenPassTokens {
        
        var components = URLComponents(string: authAPIUrl)
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
        request.httpBody = components?.query?.data(using: .utf8)
        
        let data = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let tokenResponse = try decoder.decode(OpenPassTokensResponse.self, from: data)
        
        if let tokenError = tokenResponse.error, !tokenError.isEmpty {
            throw OpenPassError.tokenData(name: tokenError, description: tokenResponse.errorDescription, uri: tokenResponse.errorUri)
        }
        
        guard let openPassTokens = tokenResponse.toOpenPassTokens() else {
            throw OpenPassError.tokenData(name: "OpenPassToken Generator", description: "Unable to generate OpenPassTokens from server", uri: nil)
        }
        
        return openPassTokens
    }
    
    func verifyIDToken(_ openPassTokens: OpenPassTokens) async throws -> Bool {
        
        // Get JWKS
        var components = URLComponents(string: authAPIUrl)
        components?.path = "/.well-known/jwks"
        
        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw OpenPassError.urlGeneration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let jwksData = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let jwksResponse = try decoder.decode(JWKS.self, from: jwksData)
        
        // Use first key provided
        guard let jwk = jwksResponse.keys.first else {
            throw OpenPassError.invalidJWKS
        }
        
        return jwk.verify(openPassTokens.idTokenJWT)
    }
    
    func generateUID2Tokens(accessToken: String) async throws -> OpenPassUID2Tokens {

            var components = URLComponents(string: authAPIUrl)
            components?.path = "/v1/api/uid2/generate"

            guard let urlPath = components?.url?.absoluteString,
                  let url = URL(string: urlPath) else {
                throw OpenPassError.urlGeneration
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let data = try await session.loadData(for: request)
                    
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tokenResponse = try decoder.decode(OpenPassUID2TokensResponse.self, from: data)

            if let tokenError = tokenResponse.error, !tokenError.isEmpty {
                throw OpenPassError.tokenData(name: tokenError, description: tokenResponse.errorDescription, uri: tokenResponse.errorUri)
            }

            guard let openPassUId2Tokens = tokenResponse.toOpenPassUID2Tokens() else {
                throw OpenPassError.tokenData(name: "OpenPass UID2 Generator",
                                              description: "Unable to generate OpenPassUID2Tokens from server",
                                              uri: nil)
            }
            
            return openPassUId2Tokens
        }
}
