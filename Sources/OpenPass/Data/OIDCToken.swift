//
//  OIDCToken.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

/// Data object for OpenPass ID and Access Tokens
public struct OIDCToken: Codable {
    
    public let idToken: String
    public let accessToken: String
    public let tokenType: String

}
