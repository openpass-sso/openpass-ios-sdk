//
//  IDTokenValidation.swift
//
// MIT License
//
// Copyright (c) 2024 The Trade Desk (https://www.thetradedesk.com/)
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

/// Validates an IDToken against JWKS.
protocol IDTokenValidation {
    func validate(_ token: IDToken, jwks: JWKS) throws -> Bool
}

/// Validates the following:
/// - Token is not expired
/// - Token issue date is not in the past
/// - Token signature is correct according to JWKS
///  https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
internal struct IDTokenValidator: IDTokenValidation {
    /// Set a specific leeway window in seconds in which the Expires At ("exp") Claim will still be valid.
    private let expiresAtLeeway: Double = 0

    /// Set a specific leeway window in seconds in which the Issued At ("iat") Claim will still be valid. This method
    /// overrides the value set with acceptLeeway(long). By default, the Issued At claim is always verified
    /// when the value is present
    private let issuedAtLeeway: Double = 60

    /// Expected client identifier audience value
    let clientID: String
    
    /// Expected issuer identifier
    let issuerID: String

    private let dateGenerator: DateGenerator

    init(
        clientID: String,
        issuerID: String,
        dateGenerator: DateGenerator = .init { Date() }
    ) {
        self.clientID = clientID
        self.issuerID = issuerID
        self.dateGenerator = dateGenerator
    }

    func validate(_ token: IDToken, jwks: JWKS) throws -> Bool {
        // Verify the issuer.
        guard token.issuerIdentifier == issuerID else {
            return false
        }

        // Check that the audience matches our expected client identifier.
        guard token.audience == clientID else {
            return false
        }

        let date = self.dateGenerator.now
        // Expiration Check
        let expiresPlusLeeway = Double(token.expirationTime) + (expiresAtLeeway * 1000)
        if date.timeIntervalSince1970 > expiresPlusLeeway {
            return false
        }

        // Issued At Check
        // Leeway is to account for device clock being earlier than server
        let issuedAtMinusLeeway = Double(token.issuedTime) - (issuedAtLeeway * 1000)
        if date.timeIntervalSince1970 < issuedAtMinusLeeway {
            return false
        }

        // Look for matching Keys between JWTS and JWK
        guard let jwk = jwks.keys.first(where: { token.keyId == $0.keyId }) else {
            throw OpenPassError.invalidJWKS
        }

        return jwk.verify(token.idTokenJWT)
    }
}

internal struct DateGenerator {
    private var generate: () -> Date

    init(_ generate: @escaping () -> Date) {
        self.generate = generate
    }

    var now: Date {
        get {
            generate()
        }
        set {
            generate = { newValue }
        }
    }
}
