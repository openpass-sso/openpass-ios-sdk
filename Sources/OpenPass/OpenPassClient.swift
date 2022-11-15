//
//  OpenPassClient.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import CryptoKit
import Foundation

class OpenPassClient {

    private let authAPIUrl: String
    private let session: NetworkSession
    
    init(authAPIUrl: String, _ session: NetworkSession = URLSession.shared) {
        self.authAPIUrl = authAPIUrl
        self.session = session
    }
    
    func getTokenFromAuthCode(clientId: String, code: String, redirectUri: String) async throws -> OIDCToken {
        
        var components = URLComponents(string: authAPIUrl)
        components?.path = "/v1/api/token"
        
        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw URLError()
        }
        
        let challengeData = Data(randomString(length: 32).utf8)
        let challengeHash = SHA256.hash(data: challengeData)
        let challengeHashString = challengeHash.compactMap { String(format: "%02x", $0) }.joined()
        
        let json = [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "redirect_uri": redirectUri,
            "code": code,
            "code_verifier": challengeHashString
        ]
        
        let jsonData = try JSONEncoder().encode(json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let data = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(OIDCToken.self, from: data)
    }
    
    func generateUID2Token(accessToken: String) async throws -> UID2Token {

        var components = URLComponents(string: authAPIUrl)
        components?.path = "/v1/api/uid2/generate"

        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw URLError()
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer: \(accessToken)", forHTTPHeaderField: "Authorization")
        let data = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(UID2Token.self, from: data)
    }
    
    /// Creates a pseudo-random string containing basic characters using Array.randomElement()
    /// - Parameter length: Desired string length
    /// - Returns: Random string
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
}

class URLError: Error { }
