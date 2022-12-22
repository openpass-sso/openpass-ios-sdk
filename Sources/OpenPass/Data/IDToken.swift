//
//  IDToken.swift
//  
//
//  Created by Brad Leege on 12/21/22.
//

import Foundation

/// OIDC ID Token
/// https://openid.net/specs/openid-connect-core-1_0.html#IDToken
public struct IDToken: Codable {
    
    private let idTokenJWT: String
    
    // Required Data
    public let iss: String
    public let sub: String
    public let aud: String
    public let exp: Int64
    public let iat: Int64
    
    // Optional Data
    public let authTime: String?
    public let nonce: String?
    public let acr: String?
    public let amr: String?
    public let azp: String?
    
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
        
        self.iss = issString
        self.sub = subString
        self.aud = audString
        self.exp = expInt
        self.iat = iatInt

        self.authTime = payloadDecoded?["auth_time"] as? String
        self.nonce = payloadDecoded?["nonce"] as? String
        self.acr = payloadDecoded?["acr"] as? String
        self.amr = payloadDecoded?["amr"] as? String
        self.azp = payloadDecoded?["azp"] as? String
        
    }
    
}
