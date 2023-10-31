//
//  DeviceCodeResponse.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Foundation


/// Internal data object for processing the response from `/v1/api/device/code`.
struct DeviceCodeResponse {
    
    let deviceCode: String
    let userCode: String
    let verificationUri: String
    let verificationUriComplete: String?
    let expiresIn: Int64
    let interval: Int64?
    
}
