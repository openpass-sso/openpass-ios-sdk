//
//  APIJWKSResponse.swift
//  
//
//  Created by Brad Leege on 12/7/22.
//

import Foundation

struct APIJWKSResponse: Codable {
    
    let keys: [JWK]
    
}

struct JWK: Codable {
    
    let keyId: String
    let keyType: String
    let exponent: String
    let modulus: String
    
    enum CodingKeys: String, CodingKey {
        case keyId = "kid"
        case keyType = "kty"
        case exponent = "e"
        case modulus = "n"
    }
    
}
