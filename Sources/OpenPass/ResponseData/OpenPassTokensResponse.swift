//
//  OpenPassTokensResponse.swift
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

/// Access Token Response for `/v1/api/token`
/// [https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.4](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.4)

enum OpenPassTokensResponse: Hashable, Decodable {
    case success(Success)
    case failure(Error)

    /// [https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1)
    struct Success: Hashable, Decodable {
        let accessToken: String
        let tokenType: String

        /// Number of seconds until `accessToken` expires
        let expiresIn: Int64?

        let idToken: String?

        /// Number of seconds until `idToken` expires
        let idTokenExpiresIn: Int64?

        let refreshToken: String?

        /// Number of seconds until `refreshToken` expires
        let refreshTokenExpiresIn: Int64?
    }

    /// [https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2)
    struct Error: Hashable, Decodable {
        let error: String?
        let errorDescription: String?
        let errorUri: String?
    }

    init(from decoder: any Decoder) throws {
        if let success = try? Success(from: decoder) {
            self = .success(success)
        } else {
            // All error properties are optional
            self = try .failure(Error(from: decoder))
        }
    }
}
