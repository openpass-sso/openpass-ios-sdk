//
//  AuthenticationState.swift
//  
//
//  Created by Brad Leege on 11/22/22.
//

import Foundation

public struct AuthenticationTokens: Codable {
    
    public let authorizeCode: String
    public let authorizeState: String
    public let oidcToken: OIDCToken
    
}

extension AuthenticationTokens {
    
    func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    static func fromData(_ data: Data) -> AuthenticationTokens? {
        let decoder = JSONDecoder()
        return try? decoder.decode(AuthenticationTokens.self, from: data)
    }
    
}
