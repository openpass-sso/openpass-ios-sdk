//
//  OpenPassClient.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

@available(iOS 13.0, *)
final class OpenPassClient {

    private let authAPIUrl: String
    private let session: NetworkSession
    
    init(authAPIUrl: String, _ session: NetworkSession = URLSession.shared) {
        self.authAPIUrl = authAPIUrl
        self.session = session
    }
    
    func getTokenFromAuthCode(clientId: String, code: String, codeVerifier: String, redirectUri: String) async throws -> OIDCToken {
        
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
        let oidcToken = try decoder.decode(OIDCToken.self, from: data)
        
        if let tokenError = oidcToken.error, !tokenError.isEmpty {
            throw OpenPassError.tokenData(name: oidcToken.error, description: oidcToken.errorDescription, uri: oidcToken.errorUri)
        }
                
        return oidcToken
    }
    
    func generateUID2Token(accessToken: String) async throws -> UID2Token {

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
        let uid2Token = try decoder.decode(UID2Token.self, from: data)

        if let tokenError = uid2Token.error, !tokenError.isEmpty {
            throw OpenPassError.tokenData(name: uid2Token.error, description: uid2Token.errorDescription, uri: uid2Token.errorUri)
        }

        return uid2Token
    }
    
}
