//
//  DeviceTokenResponse.swift
//
//
//  Created by Brad Leege on 11/8/23.
//

import Foundation

struct DeviceTokenResponse: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int64?
    let error: String?
    let errorDescription: String?
    
}
