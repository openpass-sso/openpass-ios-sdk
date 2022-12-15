//
//  OpenPassError.swift
//  
//
//  Created by Brad Leege on 10/21/22.
//

import Foundation
    
/// OpenPass specific Errors

@available(iOS 13.0, *)
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
    
    /// Error creating public key
    case publicKeyError
    
    /// Generic error
    case authorizationError(code: String, description: String)
    
    /// Unable to generate an OpenPass URL
    case urlGeneration
}
