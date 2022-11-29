//
//  UID2Token.swift
//  
//
//  Created by Brad Leege on 11/10/22.
//

import Foundation

public struct UID2Token: Codable {
    
    public let advertisingToken: String
    public let identityExpires: Int
    public let refreshToken: String
    public let refreshFrom: Int
    public let refreshExpires: Int
    public let refreshResponseKey: String

}
