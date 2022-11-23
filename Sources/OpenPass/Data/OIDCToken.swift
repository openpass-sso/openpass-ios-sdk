//
//  OIDCToken.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

public struct OIDCToken: Codable {
    
    let idToken: String
    let accessToken: String
    let tokenType: String

}
