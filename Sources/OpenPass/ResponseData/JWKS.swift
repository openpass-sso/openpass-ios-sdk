//
//  JWKS.swift
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

import Foundation
import Security

internal struct JWKS: Codable {
    
    let keys: [JWK]
    
}

extension JWKS {

    internal struct JWK: Codable {
        
        let keyId: String
        let keyType: String
        let exponent: String
        let modulus: String
        
    }

}

extension JWKS.JWK {
    
    internal enum Algorithm: String, CaseIterable {
        case rsa = "RSA"
    }
    
    internal enum CodingKeys: String, CodingKey {
        case keyId = "kid"
        case keyType = "kty"
        case exponent = "e"
        case modulus = "n"
    }

}

extension JWKS.JWK {

    internal var rsaPublicKey: SecKey? {
        guard keyType == JWKS.JWK.Algorithm.rsa.rawValue,
            let modulus = modulus.decodeBase64URLSafe(),
            let exponent = exponent.decodeBase64URLSafe() else { return nil }
        let encodedKey = encodeRSAPublicKey(modulus: [UInt8](modulus), exponent: [UInt8](exponent))
        return generateRSAPublicKey(from: encodedKey)
    }

}

extension JWKS.JWK {

    internal func encodeRSAPublicKey(modulus: [UInt8], exponent: [UInt8]) -> Data {
        var prefixedModulus: [UInt8] = [0x00] // To indicate that the number is not negative
        prefixedModulus.append(contentsOf: modulus)
        let encodedModulus = prefixedModulus.derEncode(as: 2) // Integer
        let encodedExponent = exponent.derEncode(as: 2) // Integer
        let encodedSequence = (encodedModulus + encodedExponent).derEncode(as: 48) // Sequence
        return Data(encodedSequence)
    }

    internal func generateRSAPublicKey(from derEncodedData: Data) -> SecKey? {
        let sizeInBits = derEncodedData.count * MemoryLayout<UInt8>.size
        let attributes: [CFString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                           kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                           kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
                                           kSecAttrIsPermanent: false]
        return SecKeyCreateWithData(derEncodedData as CFData, attributes as CFDictionary, nil)
    }

}

extension JWKS.JWK {
    
    internal func verify(_ jwt: String) -> Bool {
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
