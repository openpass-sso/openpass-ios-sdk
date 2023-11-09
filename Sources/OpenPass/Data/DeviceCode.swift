//
//  DeviceCode.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Foundation

/// The information required to prompt the user to authenticate via a separate device.
@available(tvOS 16.0, *)
public struct DeviceCode {

     /// The code that the user is required to enter at the location defined by the verification uri.
    public let userCode: String

    /// The website the user is required to navigate too and enter the provided code.
    public let verificationUri: String

    /// The complete uri that includes the verification address as well as the code. This can be used to generate a QR
    /// code for the user to use, to simplify navigation.
    public let verificationUriComplete: String?

    /// The epoch based time (in milliseconds) when the user code expires.
    public let expiresTimeMs: Int64
    
}
