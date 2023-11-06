//
//  DeviceCodeResponse.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Foundation

/// Internal data object for processing the response from `/v1/api/device/code`.
struct DeviceCodeResponse: Codable {
    
    let deviceCode: String
    let userCode: String
    let verificationUri: String
    let verificationUriComplete: String?
    let expiresIn: Int64
    let interval: Int64?
    
     /// Converts the response into a [DeviceCode].
    func toDeviceCode(epochTimeMs: Int64) -> DeviceCode {
        return DeviceCode(userCode: userCode,
                          verificationUri: verificationUri,
                          verificationUriComplete: verificationUriComplete,
                          expiresTimeMs: epochTimeMs + (expiresIn * 1000))
    }
    
}
