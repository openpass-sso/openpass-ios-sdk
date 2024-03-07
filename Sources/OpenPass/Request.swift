//
//  Request.swift
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

enum Method: String {
    case get = "GET"
    case post = "POST"
}

struct Request<ResponseType> {
    var method: Method
    var path: String
    var queryItems: [URLQueryItem]
    var body: Data?

    init(path: String, method: Method = .get, queryItems: [URLQueryItem] = [], body: Data? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
    }
}

// MARK: - Tokens

extension Request where ResponseType == OpenPassTokensResponse {
    static func authorizationCode(
        clientId: String,
        code: String,
        codeVerifier: String,
        redirectUri: String
    ) -> Request<OpenPassTokensResponse> {
        .init(
            path: "/v1/api/token",
            method: .post,
            queryItems: [
                .init(name: "client_id", value: clientId),
                .init(name: "code_verifier", value: codeVerifier),
                .init(name: "code", value: code),
                .init(name: "grant_type", value: "authorization_code"),
                .init(name: "redirect_uri", value: redirectUri)
            ]
        )
    }

    static func refresh(
        clientId: String,
        refreshToken: String
    ) -> Request<OpenPassTokensResponse> {
        .init(
            path: "/v1/api/token",
            method: .post,
            queryItems: [
                .init(name: "client_id", value: clientId),
                .init(name: "grant_type", value: "refresh_token"),
                .init(name: "refresh_token", value: refreshToken)
            ]
        )
    }
}
