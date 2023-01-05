//
//  OpenPassTokens.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

/// Data object for OpenPass ID and Access Tokens
public struct OpenPassTokens: Codable {
    
    public let idToken: IDToken?
    public let idTokenJWT: String
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int64

    init(idTokenJWT: String, accessToken: String, tokenType: String, expiresIn: Int64) {
        self.idTokenJWT = idTokenJWT
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn

        self.idToken = IDToken(idTokenJWT: idTokenJWT)
    }
    
}

extension OpenPassTokens {
    
    func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    static func fromData(_ data: Data) -> OpenPassTokens? {
        let decoder = JSONDecoder()
        return try? decoder.decode(OpenPassTokens.self, from: data)
    }

}
