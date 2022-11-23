//
//  APITokenResponse.swift
//  
//
//  Created by Brad Leege on 11/23/22.
//

import Foundation

struct APIOIDCTokenResponse: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let error: String?
    let errorDescription: String?
    let errorUri: String?

    var toOIDCToken: OIDCToken {
        return OIDCToken(idToken: idToken, accessToken: accessToken, tokenType: tokenType)
    }
}
