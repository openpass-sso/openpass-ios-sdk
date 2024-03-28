//
//  OpenPassError.swift
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
    
/// OpenPass specific Errors
@available(iOS 13.0, tvOS 16.0, *)
enum OpenPassError: Error {
    
    /// OpenPassManager could not find any or all of required configuration data from `Info.plist`:
    case missingConfiguration
    
    /// OpenPassManager could not generate a URL for the Authorization Web site
    case authorizationUrl
    
    /// User Initiated Cancellation of Authentication Flow
    case authorizationCancelled
    
    /// OpenPassManager Callback URL missing querystring data
    case authorizationCallBackDataItems
    
    /// Customizable error for when `OpenPassClient` Token API calls fail
    case tokenData(name: String?, description: String?, uri: String?)
    
    /// Authorization is pending error returned from `OpenPassClient` Token API call fails
    case tokenAuthorizationPending(name: String, description: String?)

    /// Slow down error returned from `OpenPassClient` Token API call fails
    case tokenSlowDown(name: String, description: String?)

    /// Token has expired error returned from `OpenPassClient` Token API call fails
    case tokenExpired(name: String, description: String?)
    
    /// OIDCToken failed verification
    case verificationFailedForOIDCToken
    
    /// JWKS is invalid
    case invalidJWKS
        
    /// Generic error
    case authorizationError(code: String, description: String)
    
    /// Unable to generate an OpenPass URL
    case urlGeneration
    
    /// Unable to generate a Device Code
    case unableToGenerateDeviceCode(name: String, description: String?)
    
    /// Unable to generate an OpenPass Token from a Device Code
    case unableToGenerateTokenFromDeviceCode
    
}

/// Specific errors returned by API Server via `error` field
internal enum DeviceAccessTokenError: String {
    case authorizationPending = "authorization_pending"
    case slowDown = "slow_down"
    case expiredToken = "expired_token"
}
