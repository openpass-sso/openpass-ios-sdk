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
///
/// [https://openid.net/specs/openid-connect-core-1_0.html#IDToken](https://openid.net/specs/openid-connect-core-1_0.html#IDToken)
@available(iOS 13.0, *)
public struct IDToken: Codable {
    
    private let idTokenJWT: String
    
    // MARK: - IDToken Header Data
    /// ID of the key used to sign the token
    public let keyId: String
    
    /// Type of token
    public let tokenType: String
    
    /// Signing algorithm used
    public let algorithm: String
    
    // MARK: - IDToken Payload Data
    
    /// ID Token - Issue Identifier
    public let issuerIdentifier: String

    /// ID Token - Subject Identifier
    public let subjectIdentifier: String

    /// ID Token - Audience
    public let audience: String

    /// ID Token - Expiration Time in milliseconds
    public let expirationTime: Int64

    /// ID Token - Issued At Time in milliseconds
    public let issuedTime: Int64
    
    // MARK: - OpenPass Data

    /// Email address provided by user
    public let email: String?
    
    /// Primary Constructor
    /// - Parameter idTokenJWT: ID Token as a JWT
    public init?(idTokenJWT: String) {
        self.idTokenJWT = idTokenJWT
        
        let components = idTokenJWT.components(separatedBy: ".")
        if components.count != 3 {
            return nil
        }
        
        let header = components[0]
        let headerDecoded = header.decodeJWTComponent()
        guard let kidString = headerDecoded?["kid"] as? String,
              let typString = headerDecoded?["typ"] as? String,
              let algString = headerDecoded?["alg"] as? String else {
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
        
        self.keyId = kidString
        self.tokenType = typString
        self.algorithm = algString
        
        self.issuerIdentifier = issString
        self.subjectIdentifier = subString
        self.audience = audString
        self.expirationTime = expInt
        self.issuedTime = iatInt
     
        self.email = payloadDecoded?["email"] as? String
        
    }
    
}
