//
//  IDToken.swift
//  
//
//  Created by Brad Leege on 12/21/22.
//

import Foundation

/// OIDC ID Token Data Object
/// https://openid.net/specs/openid-connect-core-1_0.html#IDToken
public struct IDToken: Codable {
    
    private let idTokenJWT: String
    
    // Required Spec Data
    public let issuerIdentifier: String
    public let subjectIdentifier: String
    public let audience: String
    public let expirationTime: Int64
    public let issuedTime: Int64
    
    // OpenPass Data
    public let email: String?
    
    init?(idTokenJWT: String) {
        self.idTokenJWT = idTokenJWT
        
        let components = idTokenJWT.components(separatedBy: ".")
        if components.count != 3 {
            return nil
        }
        let payload = components[1]
        let payloadDecoded = payload.decodeJWTComponent()
        
        guard let issString = payloadDecoded?["iss"] as? String,
              let subString = payloadDecoded?["sub"] as? String,
              let audString = payloadDecoded?["aud"] as? String,
              let expInt = payloadDecoded?["exp"] as? Int64,
              let iatInt = payloadDecoded?["iat"] as? Int64 else {
            return nil
        }
        
        self.issuerIdentifier = issString
        self.subjectIdentifier = subString
        self.audience = audString
        self.expirationTime = expInt
        self.issuedTime = iatInt
     
        self.email = payloadDecoded?["email"] as? String
        
    }
    
}
