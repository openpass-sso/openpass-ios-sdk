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

extension AuthenticationState {
    
    func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    static func fromData(_ data: Data) -> AuthenticationState? {
        let decoder = JSONDecoder()
        return try? decoder.decode(AuthenticationState.self, from: data)
    }
    
}
