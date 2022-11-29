//
//  APITokenResponse.swift
//  
//
//  Created by Brad Leege on 11/23/22.
//

import Foundation

/// Internal data object for processing response from `/v1/api/token`
internal struct APIOIDCTokenResponse: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let error: String?
    let errorDescription: String?
    let errorUri: String?
    
    func toOIDCToken() -> OIDCToken? {
        
        guard let idToken = idToken, let accessToken = accessToken, let tokenType = tokenType else {
            return nil
        }
        
        return OIDCToken(idToken: idToken, accessToken: accessToken, tokenType: tokenType)
    }
    
}
