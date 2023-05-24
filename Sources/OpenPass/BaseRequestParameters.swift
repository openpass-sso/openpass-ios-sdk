//
//  BaseNetworkParameters.swift
//
// MIT License
//
// Copyright (c) 2022 The Trade Desk (https://www.thetradedesk.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    // TODO - Header Type (with OP-SDK-X style)
//    var postHeaders:
    
    
    /// Parameters converted to URLQueryItems for use in Request Query strings
    var asQueryItems: [URLQueryItem] {
        return Key.allCases.map { key in
            URLQueryItem(name: key.rawValue, value: parameterMap[key])
        }
    }
    
}
