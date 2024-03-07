//
//  OpenPassTokens.swift
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

/// Data object for OpenPass ID and Access Tokens
@available(iOS 13.0, tvOS 16.0, *)
public struct OpenPassTokens: Hashable, Codable {

    /// ID Token constructed via `idTokenJWT`
    public let idToken: IDToken?
    
    /// ID token as JWT
    public let idTokenJWT: String

    /// Access Token
    public let accessToken: String

    /// Type of Access Token
    public let tokenType: String

    /// Expiration Time of Access Token in UTC
    public let expiresIn: Int64
}

extension OpenPassTokens {
    /// Primary Constructor
    /// - Parameters:
    ///   - idTokenJWT: ID Token as JWT
    ///   - accessToken: Access Token
    ///   - tokenType: Type of Access Token
    ///   - expiresIn: Exipiration time of token, represented in UTC
    public init(idTokenJWT: String, accessToken: String, tokenType: String, expiresIn: Int64) {
        self.init(
            idToken: IDToken(idTokenJWT: idTokenJWT),
            idTokenJWT: idTokenJWT,
            accessToken: accessToken,
            tokenType: tokenType,
            expiresIn: expiresIn
        )
    }

    init?(_ response: OpenPassTokensResponse) {
        guard let idToken = response.idToken,
              let expiresIn = response.expiresIn else {
            return nil
        }

        self.init(
            idTokenJWT: idToken,
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            expiresIn: expiresIn
        )
    }
}

extension OpenPassTokens {
    
    /// Convert self to Data
    /// - Returns: `OpenPassTokens` as Data
    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    /// Convert Data to `OpenPassTokens`
    /// - Parameter data: Data representation of `OpenPassTokens`
    /// - Returns: `OpenPassTokens` if decoding is successful, `nil` if not successful
    public static func fromData(_ data: Data) -> OpenPassTokens? {
        let decoder = JSONDecoder()
        return try? decoder.decode(OpenPassTokens.self, from: data)
    }
}
