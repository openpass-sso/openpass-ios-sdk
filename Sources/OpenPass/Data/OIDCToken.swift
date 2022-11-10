//
//  OIDCToken.swift
//  
//
//  Created by Brad Leege on 11/4/22.
//

import Foundation

struct OIDCToken: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let error: String?
    let errorDescription: String?
    let errorUri: String?

}
