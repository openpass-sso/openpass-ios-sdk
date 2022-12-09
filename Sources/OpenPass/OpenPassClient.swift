//
//  OpenPassClient.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import CryptoKit
import Foundation

/// Networking layer

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
        let tokenResponse = try decoder.decode(APIOIDCTokenResponse.self, from: data)
        
        if let tokenError = tokenResponse.error, !tokenError.isEmpty {
            throw OpenPassError.tokenData(name: tokenError, description: tokenResponse.errorDescription, uri: tokenResponse.errorUri)
        }
        
        guard let oidcToken = tokenResponse.toOIDCToken() else {
            throw OpenPassError.tokenData(name: "OIDC Generator", description: "Unable to generate OIDCToken from server", uri: nil)
        }
                
        return oidcToken
    }
        
    func verifyOID2Token(_ oidcToken: OIDCToken) async throws -> Bool {

        // Verify OIDCToken
        
        // Get JWKS
        var components = URLComponents(string: authAPIUrl)
        components?.path = ".well-known/jwks"
        
        guard let urlPath = components?.url?.absoluteString,
              let url = URL(string: urlPath) else {
            throw OpenPassError.urlGeneration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let jwksData = try await session.loadData(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let jwksResponse = try decoder.decode(APIJWKSResponse.self, from: jwksData)
        
        // Deconstruct OIDC ID Token for evaluation
        
        let jwt = oidcToken.idToken
        let parts = jwt.components(separatedBy: ".")

        if parts.count != 3 {
            throw OpenPassError.invalidJWT
        }

        let header = parts[0]
        let payload = parts[1]
        let signature = parts[2]
        
        // Create public key data
        guard let publicKeyText = jwksResponse.keys.first?.exponent else {
            throw OpenPassError.invalidJWT
        }

        // TODO
        // https://gist.github.com/invariant/67c1d71b54b0d7e4b5c665c6e305dc64
        
        
        
        let dataPublicKey = Data(base64Encoded: publicKeyText)

        // Create signed data
        let dataSigned = (header + "." + payload).data(using: .utf8)!
        
        // Create signature data
        let dataSignature = Data(base64Encoded: signature.base64StringWithPadding())
        
        guard let dataPublicKey = dataPublicKey, let dataSignature = dataSignature else {
            throw OpenPassError.publicKeyError
        }
        
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ]
        
        // 1- Create a 'SecKey' instance from our public key data.
        guard let publicKey = SecKeyCreateWithData(dataPublicKey as CFData, attributes as CFDictionary, nil) else {
            throw OpenPassError.publicKeyError
        }

        // 2- Define the algorithm
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256

        // 3- Verify the RSA signature.
        let result = SecKeyVerifySignature(publicKey,
                                           algorithm,
                                           dataSigned as NSData,
                                           dataSignature as NSData,
                                           nil)

        print(result)
        return result
        
        
        // TODO: Verify ID Token
        // Needs Public Key endpoint to do
        // auth.dev.myopenpass.com/.well-known/jwks
        // Look for kid
        // Make an RSA Key and use to verify the JWT
        
        // User should get decoded ID Token
        // User should get not decoded Access Token
        // Before we store verify the JWT (ID Token)

        
        // TODO: Remove Temp Data
//        return true
    }
    
}
