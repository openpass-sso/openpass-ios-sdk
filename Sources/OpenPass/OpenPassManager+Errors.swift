//
//  File.swift
//  
//
//  Created by Brad Leege on 10/21/22.
//

import Foundation

extension OpenPassManager {
    
    // TODO: - Consolidate errors in single errror type with enum and description
    
    /// OpenPassManager could not find any or all of required configuration data from `Info.plist`:
    /// * OpenPassAuthenticationURL
    /// * OpenPassClientId
    /// * OpenPassRedirectURI
    final class MissingConfigurationDataError: Error { }
    
    /// OpenPassManager could not generate a URL for the Authorization Web site
    final class AuthorizationURLError: Error { }
 
    /// User Initiated Cancellation of Authentication Flow
    final class AuthorizationCancelledError: Error { }
    
    /// OpenPassManager Callback URL missing querystring data
    final class AuthorizationCallBackDataItemsError: Error { }
    
    /// Customizable error for when `OpenPassClient` Token API calls fail
    struct TokenDataError: Error {
        var error: String? = nil
        var errorDescription: String? = nil
        var errorUri: String? = nil
    }
    
    /// Generic error
    final class AuthorizationError: Error {
        var code: String
        var description: String
        
        init(_ code: String, _ description: String) {
            self.code = code
            self.description = description
        }
    }
}
