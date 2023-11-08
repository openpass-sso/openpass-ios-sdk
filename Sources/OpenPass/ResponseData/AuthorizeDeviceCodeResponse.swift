//
//  AuthorizeDeviceCodeResponse.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Foundation

/// Transfer data object for processing the response from `/v1/api/authorize-device`.
internal struct AuthorizeDeviceCodeResponse: Codable {
    
    let deviceCode: String?
    let userCode: String?
    let verificationUri: String?
    let verificationUriComplete: String?
    let expiresIn: Int64?
    let interval: Int64?
    let error: String?
    let errorDescription: String?
    
     /// Converts the response into a ``DeviceCode``.
    func toDeviceCode(epochTimeMs: Int64) -> DeviceCode? {
        guard let userCode = userCode,
              let verificationUri = verificationUri,
              let verificationUriComplete = verificationUriComplete,
              let expiresIn = expiresIn else {
            return nil
        }
        
        return DeviceCode(userCode: userCode,
                          verificationUri: verificationUri,
                          verificationUriComplete: verificationUriComplete,
                          expiresTimeMs: epochTimeMs + (expiresIn * 1000))
    }
    
}
