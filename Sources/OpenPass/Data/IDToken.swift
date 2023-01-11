//
//  IDToken.swift
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
