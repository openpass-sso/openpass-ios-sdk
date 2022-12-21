//
//  OIDCToken.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

/// Data object for OpenPass ID and Access Tokens
public struct OpenPassTokens: Codable {
    
    public let idToken: IDToken
    public let idTokenJWT: String
    public let accessToken: String
    public let tokenType: String

    init(idTokenJWT: String, accessToken: String, tokenType: String) {
        self.idTokenJWT = idTokenJWT
        self.accessToken = accessToken
        self.tokenType = tokenType

        self.idToken = IDToken()
    }
    
    enum CodingKeys: String, CodingKey {
        case idToken
        case idTokenJWT = "id_token"
        case accessToken
        case tokenType
    }
    
}
