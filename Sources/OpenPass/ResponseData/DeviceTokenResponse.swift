//
//  DeviceTokenResponse.swift
//
//
//  Created by Brad Leege on 11/8/23.
//

import Foundation

/// Transfer data object for processing response from `/v1/api/device-token`
internal struct DeviceTokenResponse: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int64?
    let error: String?
    let errorDescription: String?
    
    /// Specific errors returned by API Server via `error` field
    private enum Errors: String {
        case authorizationPending = "authorization_pending"
        case slowDown = "slow_down"
        case expiredToken = "expired_token"
    }
    
    func toOpenPassTokens() -> OpenPassTokens? {
        
        guard let idToken = idToken, let accessToken = accessToken, let tokenType = tokenType, let expiresIn = expiresIn else {
            return nil
        }
        
        return OpenPassTokens(idTokenJWT: idToken, accessToken: accessToken, tokenType: tokenType, expiresIn: expiresIn)
    }
    
    func toError() -> OpenPassError? {
        
        guard let error = error else {
            return nil
        }
        
        if error == Errors.authorizationPending.rawValue {
            return OpenPassError.tokenAuthorizationPending(name: error, description: errorDescription)
        }
        
        if error == Errors.slowDown.rawValue {
            return OpenPassError.tokenSlowDown(name: error, description: errorDescription)
        }
        
        if error == Errors.slowDown.rawValue {
            return OpenPassError.tokenExpired(name: error, description: errorDescription)
        }

        return OpenPassError.tokenData(name: error, description: errorDescription, uri: nil)
    }
    
}
