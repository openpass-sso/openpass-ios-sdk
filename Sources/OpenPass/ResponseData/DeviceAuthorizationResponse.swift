//
//  DeviceAuthorizationResponse.swift
//
// MIT License
//
// Copyright (c) 2023 The Trade Desk (https://www.thetradedesk.com/)
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

/// Response from `/v1/api/authorize-device`.
/// https://datatracker.ietf.org/doc/html/rfc8628#section-3.2
internal enum DeviceAuthorizationResponse: Hashable, Decodable, Sendable {

    case success(Success)
    case failure(OpenPassTokensResponse.Error)

    struct Success: Hashable, Decodable, Sendable {
        let deviceCode: String
        let userCode: String
        let verificationUri: String
        let verificationUriComplete: String
        let expiresIn: Int64
        let interval: Int64
    }

    init(from decoder: any Decoder) throws {
        if let success = try? Success(from: decoder) {
            self = .success(success)
        } else {
            // All error properties are optional
            self = try .failure(OpenPassTokensResponse.Error(from: decoder))
        }
    }
}

extension DeviceCode {
    init(response: DeviceAuthorizationResponse.Success, now: Date = .init()) {
        self.init(
            userCode: response.userCode,
            verificationUri: response.verificationUri,
            verificationUriComplete: response.verificationUriComplete,
            expiresAt: now.addingTimeInterval(TimeInterval(response.expiresIn)),
            deviceCode: response.deviceCode,
            interval: response.interval
        )
    }
}
