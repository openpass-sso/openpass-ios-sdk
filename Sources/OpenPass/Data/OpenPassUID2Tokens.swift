//
//  OpenPassUID2Tokens.swift
//  
//
//  Created by Brad Leege on 1/5/23.
//

import Foundation

public struct OpenPassUID2Tokens: Codable {
    
    public let advertisingToken: String
    public let identityExpires: Int
    public let refreshToken: String
    public let refreshFrom: Int64
    public let refreshExpires: Int64
    public let refreshResponseKey: String
    
}
