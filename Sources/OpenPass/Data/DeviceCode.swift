//
//  DeviceCode.swift
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

/// The information required to prompt the user to authenticate via a separate device.
public struct DeviceCode: Hashable, Sendable {

    /// The code that the user is required to enter at the location defined by the verification uri.
    public let userCode: String

    /// The uri the user is required to navigate to and enter the provided code.
    public let verificationUri: String

    /// The complete uri that includes the verification address as well as the code. This can be used to generate a QR
    /// code for the user to use, to simplify navigation.
    public let verificationUriComplete: String?

    /// The Date when the user code expires.
    public let expiresAt: Date

    /// The device code for requesting an access token
    internal let deviceCode: String

    /// The minimum polling interval
    internal let interval: Int64
}
