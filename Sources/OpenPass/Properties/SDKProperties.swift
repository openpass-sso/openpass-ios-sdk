//
//  SDKProperties.swift
//  
//
//  Created by Diego Romero on 04/04/2023.
//

import Foundation

struct SDKProperties: Codable {
    
    let sdkName: String?
    let sdkVersion: String?
    
    enum CodingKeys: String, CodingKey {
        case sdkName = "SDKName"
        case sdkVersion = "SDKVersion"
    }
}
