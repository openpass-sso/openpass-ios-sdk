//
//  UID2Token.swift
//  
//
//  Created by Brad Leege on 11/10/22.
//

import Foundation

struct UID2Token: Codable {
    
    let advertisingToken: String?
    let identityExpires: Int?
    let refreshToken: String?
    let refreshFrom: Int?
    let refreshExpires: Int?
    let refreshResponseKey: String?
    
    let error: String?
    let errorDescription: String?
    let errorUri: String?

}
