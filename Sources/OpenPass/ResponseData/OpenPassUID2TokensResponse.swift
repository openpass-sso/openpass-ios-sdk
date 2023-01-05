//
//  OpenPassUID2TokensResponse.swift
//  
//
//  Created by Brad Leege on 1/5/23.
//

import Foundation

/// Internal data object for processing response from `/v1/api/uid2/generate`
internal struct OpenPassUID2TokensResponse: Codable {
    
    public let advertisingToken: String?
    public let identityExpires: Int?
    public let refreshToken: String?
    public let refreshFrom: Int64?
    public let refreshExpires: Int64?
    public let refreshResponseKey: String?
    
    public let error: String?
    public let errorDescription: String?
    public let errorUri: String?
    
    func toOpenPassUID2Tokens() -> OpenPassUID2Tokens? {
        
        guard let advertisingToken = advertisingToken,
              let identityExpires = identityExpires,
              let refreshToken = refreshToken,
              let refreshFrom = refreshFrom,
              let refreshExpires = refreshExpires,
              let refreshResponseKey = refreshResponseKey else {
            return nil
        }
        
        return OpenPassUID2Tokens(advertisingToken: advertisingToken,
                                  identityExpires: identityExpires,
                                  refreshToken: refreshToken,
                                  refreshFrom: refreshFrom,
                                  refreshExpires: refreshExpires,
                                  refreshResponseKey: refreshResponseKey)
    }

}
