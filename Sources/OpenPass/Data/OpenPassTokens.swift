//
//  OIDCToken.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

/// Data object for OpenPass ID and Access Tokens
public struct OpenPassTokens: Codable {
    
    public let idToken: String
    public let accessToken: String
    public let tokenType: String

}

extension OpenPassTokens {
    
    var components: [String] {
        idToken.components(separatedBy: ".")
    }
    
    var header: String? {
        if components.count == 3 {
            return components[0]
        }
        return nil
    }
    
    var payload: String? {
        if components.count == 3 {
            return components[1]
        }
        return nil
    }
    
    var signature: String? {
        if components.count == 3 {
            return components[2]
        }
        return nil
    }
    
    var payloadDecoded: [String: Any]? {
        payload?.decodeJWTComponent()
    }
    
}
