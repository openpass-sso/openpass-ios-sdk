//
//  File.swift
//  
//
//  Created by Brad Leege on 10/21/22.
//

import Foundation

extension OpenPassManager {
    
    /// OpenPassManager could not find any or all of required configuration data from `Info.plist`:
    /// * OpenPassAuthenticationURL
    /// * OpenPassClientId
    /// * OpenPassRedirectURI
    final class MissingConfigurationDataError: Error { }
    
    /// OpenPassManager could not generate a URL for the Authorization Web site
    final class AuthorizationURLError: Error { }
    
}
