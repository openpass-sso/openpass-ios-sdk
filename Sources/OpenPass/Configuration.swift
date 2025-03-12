//
//  OpenPassManager.swift
//
// MIT License
//
// Copyright (c) 2025 The Trade Desk (https://www.thetradedesk.com/)
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

internal let openPassSdkVersion = "1.4.0"
internal let defaultBaseURL = URL(string: "https://auth.myopenpass.com/")!

/// The SDK name. This is being send to the API via HTTP headers to track metrics.
internal let defaultSdkName = "openpass-ios-sdk"

/// Configuration values common across SDK usage
public struct Configuration {
    public var clientId: String

    // defaults to prod
    public var environment: Environment

    public var isLoggingEnabled = false

    public var sdkNameSuffix: String? {
        didSet {
            sdkName = defaultSdkName.appending(sdkNameSuffix ?? "")
        }
    }

    internal var sdkName: String

    internal var sdkVersion: String

    // Initializer with required SDK parameters
    public init(
        clientId: String
    ) {
        self.clientId = clientId
        self.environment = .production
        self.sdkName = defaultSdkName
        self.sdkVersion = openPassSdkVersion
    }
}

extension Configuration {
    init(_ configuration: OpenPassConfiguration) {
        self.clientId = configuration.clientId

        switch configuration.baseURL {
        case Environment.production.endpoint.absoluteString:
            self.environment = .production
        case Environment.staging.endpoint.absoluteString:
            self.environment = .staging
        default:
            self.environment = .custom(url: URL(string: configuration.baseURL)!)
        }

        self.sdkName = configuration.sdkName
        self.sdkVersion = configuration.sdkVersion
    }
}
