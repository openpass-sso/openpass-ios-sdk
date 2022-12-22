//
//  JWKS.swift
//  
//
//  Created by Brad Leege on 12/7/22.
//

import Foundation
import Security

internal struct JWKS: Codable {
    
    let keys: [JWK]
    
}

extension JWKS {

    struct JWK: Codable {
        
        let keyId: String
        let keyType: String
        let exponent: String
        let modulus: String
        
    }

}

extension JWKS.JWK {
    
    enum Algorithm: String, CaseIterable {
        case rsa = "RSA"
    }
    
    enum CodingKeys: String, CodingKey {
        case keyId = "kid"
        case keyType = "kty"
        case exponent = "e"
        case modulus = "n"
    }

}

extension JWKS.JWK {

    var rsaPublicKey: SecKey? {
        guard keyType == JWKS.JWK.Algorithm.rsa.rawValue,
            let modulus = modulus.decodeBase64URLSafe(),
            let exponent = exponent.decodeBase64URLSafe() else { return nil }
        let encodedKey = encodeRSAPublicKey(modulus: [UInt8](modulus), exponent: [UInt8](exponent))
        return generateRSAPublicKey(from: encodedKey)
    }

}

extension JWKS.JWK {

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

}

extension JWKS.JWK {
    
    public func verify(_ jwt: String) -> Bool {
        let separator = "."
        let components = jwt.components(separatedBy: separator)
        let signature = components[2]
        let parts = jwt.components(separatedBy: separator).dropLast().joined(separator: separator)
        guard let data = parts.data(using: .utf8),
              let rsaPublicKey = self.rsaPublicKey,
              let signature = signature.decodeBase64URLSafe(),
              !signature.isEmpty else { return false }
        return SecKeyVerifySignature(rsaPublicKey, .rsaSignatureMessagePKCS1v15SHA256, data as CFData, signature as CFData, nil)
    }

}
