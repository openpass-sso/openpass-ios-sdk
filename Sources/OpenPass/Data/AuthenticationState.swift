//
//  AuthenticationState.swift
//  
//
//  Created by Brad Leege on 11/22/22.
//

import Foundation

public struct AuthenticationState: Codable {
    
    public let authorizeCode: String
    public let authorizeState: String
    public let oidcToken: OIDCToken
    public let uid2Token: UID2Token
    
}
