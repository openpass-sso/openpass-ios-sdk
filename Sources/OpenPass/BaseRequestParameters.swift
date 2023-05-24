//
//  BaseNetworkParameters.swift
//  
//
//  Created by Brad Leege on 5/24/23.
//

import Foundation
import UIKit

struct BaseRequestParameters {
    
    enum Key: String, CaseIterable {
        case sdkName = "sdk_name"
        case sdkVersion = "sdk_version"
        case devicePlatform = "device_platform"
        case devicePlatformVersion = "device_platform_version"
        case deviceType = "device_type"
    }
    
    let parameterMap: [Key: String]
    
    init(sdkName: String, sdkVersion: String) {
                
        parameterMap = [
            Key.sdkName: sdkName,
            Key.sdkVersion: sdkVersion,
            Key.devicePlatform: UIDevice.current.systemName,
            Key.devicePlatformVersion: UIDevice.current.systemVersion,
            Key.deviceType: UIDevice.current.model
        ]
    }
    
}
