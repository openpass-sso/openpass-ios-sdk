//
//  SDKPropertyLoader.swift
//  
//
//  Created by Diego Romero on 04/04/2023.
//

import Foundation

class SDKPropertyLoader {
    static func load() -> SDKProperties {
        
        guard let plistURL = Bundle.module.url(forResource: "sdk_properties", withExtension: "plist") else {
            return SDKProperties(sdkName: nil, sdkVersion: nil)
        }
        
        let decoder = PropertyListDecoder()
        
        guard let data = try? Data.init(contentsOf: plistURL),
              let preferences = try? decoder.decode(SDKProperties.self, from: data) else {
            return SDKProperties(sdkName: nil, sdkVersion: nil)
        }

        return preferences
    }
}
