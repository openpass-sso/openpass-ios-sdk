//
//  OpenPassClient.swift
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

import CryptoKit
import Foundation

/// Networking layer for OpenPass API Server
@available(iOS 13.0, tvOS 16.0, *)
internal final class OpenPassClient {
    
    private let baseURL: String
    private let baseRequestParameters: BaseRequestParameters
    private let clientId: String
    private let session = URLSession.shared

    init(baseURL: String, baseRequestParameters: BaseRequestParameters, clientId: String) {
        self.baseURL = baseURL
        self.baseRequestParameters = baseRequestParameters
        self.clientId = clientId
    }

    // MARK: - Tokens

    /// Network call to get an ``OpenPassTokens``
    /// - Parameters:
    ///   - code: Authorization Code from Network call to `api/authorize`
    ///   - codeVerifier: App Generated Code to verify request
    ///   - redirectUri: The app's specific URL Scheme set in `Info.plist`
    /// - Returns: Server Generated ``OpenPassTokens``
    func getTokenFromAuthCode(
        code: String,
        codeVerifier: String,
        redirectUri: String
    ) async throws -> OpenPassTokensResponse {
        let request = Request.authorizationCode(
            clientId: clientId,
            code: code,
            codeVerifier: codeVerifier,
            redirectUri: redirectUri
        )
        return try await execute(request)
    }

    /// Refresh tokens using an existing `refreshToken`
    /// - Parameters:
    ///   - refreshToken: A refresh token
    /// - Returns: Refreshed ``OpenPassTokensResponse``
    func refreshTokens(_ refreshToken: String) async throws -> OpenPassTokensResponse {
        let request = Request.refresh(
            clientId: clientId,
            refreshToken: refreshToken
        )
        return try await execute(request)
    }

    // MARK: - JWKS

    func fetchJWKS() async throws -> JWKS {
        try await execute(Request<JWKS>(path: "/.well-known/jwks"))
    }

    // MARK: - Request Execution

    private func urlRequest<ResponseType>(
        _ request: Request<ResponseType>,
        baseURL: URL,
        httpHeaders: [String: String] = [:]
    ) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = request.path

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = request.method.rawValue
        if request.method == .get {
            urlComponents.queryItems = request.queryItems
        } else if request.method == .post {
            urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = encodedPostBody(request.queryItems)
        }

        httpHeaders.forEach { field, value in
            urlRequest.addValue(value, forHTTPHeaderField: field)
        }
        return urlRequest
    }

    private func encodedPostBody(_ queryItems: [URLQueryItem]) -> Data {
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
        let query = urlComponents.query ?? ""
        return Data(query.utf8)
    }

    private func execute<ResponseType: Decodable>(_ request: Request<ResponseType>) async throws -> ResponseType {
        let urlRequest = urlRequest(
            request,
            baseURL: URL(string: baseURL)!,
            httpHeaders: baseRequestParameters.asHeaderPairs
        )
        let data = try await session.data(for: urlRequest).0
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ResponseType.self, from: data)
    }

}
