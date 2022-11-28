//
//  APIUID2TokenResponse.swift
//  
//
//  Created by Brad Leege on 11/23/22.
//

import Foundation

/// Internal data object for processing response from `/v1/api/uid2/generate`
internal struct APIUID2TokenResponse: Codable {
    
    public let advertisingToken: String?
    public let identityExpires: Int?
    public let refreshToken: String?
    public let refreshFrom: Int?
    public let refreshExpires: Int?
    public let refreshResponseKey: String?
    
    public let error: String?
    public let errorDescription: String?
    public let errorUri: String?
    
    func toUID2Token() -> UID2Token? {
        
        guard let advertisingToken = advertisingToken,
              let identityExpires = identityExpires,
              let refreshToken = refreshToken,
              let refreshFrom = refreshFrom,
              let refreshExpires = refreshExpires,
              let refreshResponseKey = refreshResponseKey else {
            return nil
        }
        
        return UID2Token(advertisingToken: advertisingToken,
                         identityExpires: identityExpires,
                         refreshToken: refreshToken,
                         refreshFrom: refreshFrom,
                         refreshExpires: refreshExpires,
                         refreshResponseKey: refreshResponseKey)
    }

}
