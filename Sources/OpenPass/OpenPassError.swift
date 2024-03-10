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
    
    /// OIDCToken failed verification
    case verificationFailedForOIDCToken
    
    /// JWKS is invalid
    case invalidJWKS
        
    /// Generic error
    case authorizationError(code: String, description: String)
    
    /// Unable to generate an OpenPass URL
    case urlGeneration
    
}
