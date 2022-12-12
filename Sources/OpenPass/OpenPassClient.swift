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
    
    @MainActor
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
        
        // Create public key data
        guard let jwk = jwksResponse.keys.first else {
            throw OpenPassError.invalidJWT
        }
        
        let parts = oidcToken.idToken.components(separatedBy: ".")

        if parts.count != 3 { fatalError("jwt is not valid!") }

        let header = parts[0]
        let payload = parts[1]
        let signature = parts[2]

        // Decode JWT Payload
        print(decodeJWTPart(part: payload) ?? "could not converted to json!")
                
        // MARK: - Verification
        
        // Build Public Key
        
        // Base 64 Decode modulus
//        let base64Modulus = a0_decodeBase64URLSafe(string: jwk.modulus)

        // These are base64 strings
        guard let n = jwk.modulus.a0_decodeBase64URLSafe(),
              let e = jwk.exponent.a0_decodeBase64URLSafe() else {
            throw OpenPassError.publicKeyError
        }
        
        let encodedKey = encodeRSAPublicKey(modulus: [UInt8](n), exponent:[UInt8](e))
        
        guard let rsaKey = generateRSAPublicKey(from: encodedKey) else {
            print("Couldn't make rsaKey")
            return false
        }
        
        // Verification
        let result = verify(oidcToken.idToken, using: rsaKey)
        
        return result
        
        // TODO: Verify ID Token
        // Needs Public Key endpoint to do
        // auth.dev.myopenpass.com/.well-known/jwks
        // Look for kid
        // Make an RSA Key and use to verify the JWT
        
        // User should get decoded ID Token
        // User should get not decoded Access Token
        // Before we store verify the JWT (ID Token)
        
    }
    
    func base64StringWithPadding(encodedString: String) -> String {
        var stringTobeEncoded = encodedString.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingCount = encodedString.count % 4
        for _ in 0..<paddingCount {
            stringTobeEncoded += "="
        }
        return stringTobeEncoded
    }
    
    func decodeJWTPart(part: String) -> [String: Any]? {
        let payloadPaddingString = base64StringWithPadding(encodedString: part)
        guard let payloadData = Data(base64Encoded: payloadPaddingString) else {
            fatalError("payload could not converted to data")
        }
            return try? JSONSerialization.jsonObject(
            with: payloadData,
            options: []) as? [String: Any]
    }

    
    func decode(_ string: String) -> [UInt8] {
        return [UInt8](string.utf8).base64URLDecodedBytes()
    }
//
//
//    /// Decodes base64url-encoded data.
//    func a0_decodeBase64URLSafe(string: String) -> String {
//        print("base64String to decode = \(string)")
//        let lengthMultiple = 4
//        let paddingLength = lengthMultiple - string.count % lengthMultiple
//        let padding = (paddingLength < lengthMultiple) ? String(repeating: "=", count: paddingLength) : ""
//        let base64EncodedString = string
//                .replacingOccurrences(of: "-", with: "+")
//                .replacingOccurrences(of: "_", with: "/")
//                + padding
////            return Data(base64Encoded: base64EncodedString)
//        print("base64EncodedString decoded = \(base64EncodedString)")
//        return base64EncodedString
//    }

    
    func encodeRSAPublicKey(modulus: [UInt8], exponent: [UInt8]) -> Data {
            var prefixedModulus: [UInt8] = [0x00] // To indicate that the number is not negative
            prefixedModulus.append(contentsOf: modulus)
            let encodedModulus = prefixedModulus.derEncode(as: 2) // Integer
            let encodedExponent = exponent.derEncode(as: 2) // Integer
            let encodedSequence = (encodedModulus + encodedExponent).derEncode(as: 48) // Sequence
            return Data(encodedSequence)
        }
 
    func generateRSAPublicKey(from derEncodedData: Data) -> SecKey? {
            let sizeInBits = derEncodedData.count * MemoryLayout<UInt8>.size
            let attributes: [CFString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                               kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                               kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
                                               kSecAttrIsPermanent: false]
            return SecKeyCreateWithData(derEncodedData as CFData, attributes as CFDictionary, nil)
        }
    
    func verify(_ jwt: String, using rsaPublicKey: SecKey) -> Bool {
            let separator = "."
            let comps = jwt.components(separatedBy: ".")

            if comps.count != 3 { fatalError("jwt is not valid!") }

            let header = comps[0]
            let payload = comps[1]
            let signature = comps[2]

            let parts = [header, payload].joined(separator: separator)
            guard let data = parts.data(using: .utf8),
                let signature = signature.a0_decodeBase64URLSafe(),
                !signature.isEmpty else {
                    return false
            }
                
        let willWork = SecKeyIsAlgorithmSupported(rsaPublicKey, .verify, .rsaSignatureMessagePKCS1v15SHA256)
        print("willWork = \(willWork)")
        
        var error: Unmanaged<CFError>? = nil
        let result = SecKeyVerifySignature(rsaPublicKey, .rsaSignatureMessagePKCS1v15SHA256, data as CFData, signature as CFData, &error)
        if error != nil {
            print("Error = \(String(describing: error))")
        }
        return result
        }
    
}

extension Array where Element == UInt8 {

    func derEncode(as dataType: UInt8) -> [UInt8] {
        var encodedBytes: [UInt8] = [dataType]
        var numberOfBytes = count
        if numberOfBytes < 128 {
            encodedBytes.append(UInt8(numberOfBytes))
        } else {
            let lengthData = Data(bytes: &numberOfBytes, count: MemoryLayout.size(ofValue: numberOfBytes))
            let lengthBytes = [UInt8](lengthData).filter({ $0 != 0 }).reversed()
            encodedBytes.append(UInt8(truncatingIfNeeded: lengthBytes.count) | 0b10000000)
            encodedBytes.append(contentsOf: lengthBytes)
        }
        encodedBytes.append(contentsOf: self)
        return encodedBytes
    }

}


public extension String {

    /// Decodes base64url-encoded data.
    func a0_decodeBase64URLSafe() -> Data? {
        let lengthMultiple = 4
        let paddingLength = lengthMultiple - count % lengthMultiple
        let padding = (paddingLength < lengthMultiple) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        return Data(base64Encoded: base64EncodedString)
    }

}

