//
//  OpenPassManagerTests.swift
//  
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

@testable import OpenPass
import XCTest
import AuthenticationServices

struct IDTokenValidationStub: IDTokenValidation {
    var valid: Bool

    func validate(_ token: IDToken, jwks: JWKS) throws -> Bool {
        valid
    }

    static let valid = Self(valid: true)
    static let invalid = Self(valid: false)
}

@available(iOS 13.0, *)
@MainActor
final class OpenPassManagerTests: XCTestCase {

    // Base64-URL Encoded String
    let codeVerifier = "2hrVVNjQL-5JuQTCqrdIgHTVIIFQnxEXGOTy1VNkuQM"

    // SHA256 digested and then Base64-URL Encoded String
    let codeChallenge = "rrw_o86gcCbS5BGxT-FUC-AoVjDyMXpRDiYjXUR0Kak"
    
    /// Runs the sign in flow with default, 'success' parameters. Override parameters to test failure scenarios.
    private func _testSignInUXFlow(
        callbackURL: URL = URL(string: "com.myopenpass.auth.test-client://com.openpass?state=state123&code=123456")!,
        authenticationState: String = "state123",
        authenticationSession: AuthenticationSession? = nil,
        overrideFixtures: [String:(String, Int)] = [:],
        tokenValidator: IDTokenValidation = IDTokenValidationStub.valid
    ) async throws -> OpenPassTokens {
        let defaultFixtures = [
            "/v1/api/token": ("openpasstokens-200", 200),
            "/.well-known/jwks": ("jwks", 200),
        ]
        // overrides in fixtures replace defaults
        let fixtures = defaultFixtures.merging(overrideFixtures) { $1 }
        try HTTPStub.shared.stub(fixtures: fixtures)

        let manager = OpenPassManager(
            clientId: "test-client",
            redirectHost: "com.openpass",
            authenticationSession: authenticationSession ?? { _, _ in callbackURL },
            authenticationStateGenerator: .init { authenticationState },
            tokenValidator: tokenValidator
        )

        return try await manager.beginSignInUXFlow()
    }

    func testSignInSuccess() async throws {
        let tokens = try await _testSignInUXFlow()
        XCTAssertNotNil(tokens, "Expected sign-in to succeed and return tokens")
    }

    func testSignInUserCancelled() async throws {
        try await assertThrowsOpenPassError(
            await self._testSignInUXFlow(
                authenticationSession: { url, callbackURLScheme in
                    throw ASWebAuthenticationSessionError(_nsError: NSError(
                        domain: ASWebAuthenticationSessionError.errorDomain,
                        code: ASWebAuthenticationSessionError.canceledLogin.rawValue
                    ))
                }
            )
        ) { error in
            XCTAssertEqual(error, .authorizationCancelled)
        }
    }

    func testSignInAuthStateMismatch() async throws {
        try await assertThrowsOpenPassError(
            await self._testSignInUXFlow(
                authenticationState: "bad state"
            )
        ) { error in
            XCTAssertEqual(error, .authorizationCallBackDataItems)
        }
    }

    func testSignInInternalServerError() async throws {
        try await assertThrowsOpenPassError(
            await self._testSignInUXFlow(
                overrideFixtures: [
                    "/v1/api/token": ("openpasstokens-500", 500),
                ]
            )
        ) { error in
            XCTAssertEqual(
                error,
                .tokenData(
                    name: "server_error",
                    description: "An unexpected error has occurred",
                    uri: "https://auth.myopenpass.com"
                )
            )
        }
    }

    func testSignInBadTokenResponse() async throws {
        try await assertThrowsOpenPassError(
            await self._testSignInUXFlow(
                overrideFixtures: [
                    "/v1/api/token": ("token-bad-data", 200),
                ]
            )
        ) { error in
            XCTAssertEqual(error, .verificationFailedForOIDCToken)
        }
    }

    func testSignInInvalidToken() async throws {
        try await assertThrowsOpenPassError(
            await self._testSignInUXFlow(
                tokenValidator: IDTokenValidationStub.invalid
            )
        ) { error in
            XCTAssertEqual(error, .verificationFailedForOIDCToken)
        }
    }

    func testGenerateCodeChallengeFromVerifierCode() {
        let manager = OpenPassManager(clientId: "123", redirectHost: "openpass")
        let generatedCodeChallenge = manager.generateCodeChallengeFromVerifierCode(verifier: codeVerifier)

        XCTAssertEqual(generatedCodeChallenge, codeChallenge, "Generated Code Challenge not generated correctly")
    }
}

internal func assertThrowsOpenPassError<T>(
    _ expression: @escaping @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: OpenPassError) -> Void = { _ in }
) async {
    // Use `Result.get` to rethrow inside `XCTAssertThrowsError` after the asynchronous `expression` is complete.
    let result = await Task {
        try await expression()
    }.result
    XCTAssertThrowsError(try result.get(), message(), file: file, line: line, { untypedError in
        guard let error = untypedError as? OpenPassError else {
            XCTFail("Expected error of type \(OpenPassError.self)")
            return
        }
        errorHandler(error)
    })
}

/// Convenience for tests only.
extension OpenPassError: Equatable {
    public static func == (lhs: OpenPassError, rhs: OpenPassError) -> Bool {
        switch (lhs, rhs) {
        case (.missingConfiguration, .missingConfiguration):
            return true
        case (.authorizationUrl, .authorizationUrl):
            return true
        case (.authorizationCancelled, .authorizationCancelled):
            return true
        case (.authorizationCallBackDataItems, .authorizationCallBackDataItems):
            return true
        case (.tokenData(let lName, let lDescription, let lUri), .tokenData(let rName, let rDescription, let rUri)):
            return lName == rName && lDescription == rDescription && lUri == rUri
        case (.verificationFailedForOIDCToken, .verificationFailedForOIDCToken):
            return true
        case (.invalidJWKS, .invalidJWKS):
            return true
        case (.authorizationError(let lCode, let lDescription), .authorizationError(let rCode, let rDescription)):
            return lCode == rCode && lDescription == rDescription
        case (.urlGeneration, .urlGeneration):
            return true
        default:
            return false
        }
    }
}
