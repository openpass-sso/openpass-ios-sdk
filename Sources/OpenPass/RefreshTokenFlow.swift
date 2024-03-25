//
//  RefreshTokenFlow.swift
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

@MainActor
public final class RefreshTokenFlow {
    private let openPassClient: OpenPassClient
    private let clientId: String
    private let tokenValidator: IDTokenValidation
    private let tokensObserver: ((OpenPassTokens) async -> Void)

    init(
        openPassClient: OpenPassClient,
        clientId: String,
        tokenValidator: IDTokenValidation,
        tokensObserver: @escaping ((OpenPassTokens) async -> Void)
    ) {
        self.openPassClient = openPassClient
        self.clientId = clientId
        self.tokenValidator = tokenValidator
        self.tokensObserver = tokensObserver
    }

    public func refreshTokens(_ refreshToken: String) async throws -> OpenPassTokens {
        let tokenResponse = try await openPassClient.refreshTokens(refreshToken)
        let openPassTokens = try OpenPassTokens(tokenResponse)
        // Validate ID Token
        guard let idToken = openPassTokens.idToken,
              try await verify(idToken) else {
            throw OpenPassError.verificationFailedForOIDCToken
        }

        await tokensObserver(openPassTokens)
        return openPassTokens
    }

    /// Verifies IDToken
    /// - Parameter idToken: ID Token To Verify
    /// - Returns: true if valid, false if invalid
    private func verify(_ idToken: IDToken) async throws -> Bool {
        let jwks = try await openPassClient.fetchJWKS()
        return try tokenValidator.validate(idToken, jwks: jwks)
    }
}
