//
//  IDTokenValidationTests.swift
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

@testable import OpenPass
import XCTest

@available(iOS 13.0, *)
final class IDTokenValidationTests: XCTestCase {

    /// 🟩 Verify that ID Token was signed as expected
    @MainActor
    func testValidateTokens() async throws {
        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let expiry = Date(timeIntervalSince1970: 1674408060)
        
        /// The 'current' date used for token validation
        var currentDate = issuedAt
        let tokenValidator = IDTokenValidator(
            clientID: "29352915982374239857",
            issuerID: "http://localhost:8888",
            dateGenerator: DateGenerator({
                currentDate
            })
        )

        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-200")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")
        let jwks = try FixtureLoader.decode(JWKS.self, fixture: "jwks")
        
        // Post Issued Time Test
        currentDate = issuedAt.addingTimeInterval(50)
        let isValid = try tokenValidator.validate(idToken, jwks: jwks)
        XCTAssertTrue(isValid, "JWT was not validated")

        // Clock Drift Too Early For Issued Time
        currentDate = issuedAt.addingTimeInterval(-150_000)
        XCTAssertFalse(try tokenValidator.validate(idToken, jwks: jwks), "JWT was validated when it should not have been")

        // Token Expired Test
        currentDate = expiry.addingTimeInterval(1)
        XCTAssertFalse(try tokenValidator.validate(idToken, jwks: jwks), "JWT was validated when it should not have been")
    }

    func testInvalidAudience() throws {
        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-200")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")
        let jwks = try FixtureLoader.decode(JWKS.self, fixture: "jwks")

        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let tokenValidator = IDTokenValidator(
            clientID: "not-the-right-client-ID",
            issuerID: "http://localhost:8888",
            dateGenerator: DateGenerator({
                issuedAt
            })
        )
        try XCTAssertFalse(tokenValidator.validate(idToken, jwks: jwks))
    }

    func testInvalidIssuer() throws {
        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-200")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")
        let jwks = try FixtureLoader.decode(JWKS.self, fixture: "jwks")

        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let tokenValidator = IDTokenValidator(
            clientID: "29352915982374239857",
            issuerID: "https://example.com",
            dateGenerator: DateGenerator({
                issuedAt
            })
        )
        try XCTAssertFalse(tokenValidator.validate(idToken, jwks: jwks))
    }

    func testInvalidSignature() throws {
        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-invalid-signature")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")
        let jwks = try FixtureLoader.decode(JWKS.self, fixture: "jwks")

        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let tokenValidator = IDTokenValidator(
            clientID: "29352915982374239857",
            issuerID: "http://localhost:8888",
            dateGenerator: DateGenerator({
                issuedAt
            })
        )
        try XCTAssertFalse(tokenValidator.validate(idToken, jwks: jwks))
    }

    func testMalformedSignature() throws {
        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-malformed-signature")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")
        let jwks = try FixtureLoader.decode(JWKS.self, fixture: "jwks")

        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let tokenValidator = IDTokenValidator(
            clientID: "29352915982374239857",
            issuerID: "http://localhost:8888",
            dateGenerator: DateGenerator({
                issuedAt
            })
        )
        try XCTAssertFalse(tokenValidator.validate(idToken, jwks: jwks))
    }

    func testInvalidJWKS() throws {
        let openPassTokensResponse = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-200")
        let idToken = try XCTUnwrap(OpenPassTokens(openPassTokensResponse).idToken, "Unable to convert to OpenPassTokens")

        let issuedAt = Date(timeIntervalSince1970: 1671816060)
        let tokenValidator = IDTokenValidator(
            clientID: "29352915982374239857",
            issuerID: "http://localhost:8888",
            dateGenerator: DateGenerator({
                issuedAt
            })
        )
        XCTAssertThrowsError(try tokenValidator.validate(idToken, jwks: JWKS(keys: [])))
    }
}
