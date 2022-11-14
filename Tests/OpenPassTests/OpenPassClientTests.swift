//
//  OpenPassClientTests.swift
//  
//
//  Created by Brad Leege on 11/7/22.
//

@testable import OpenPass
import XCTest

final class OpenPassClientTests: XCTestCase {

    /// 🟩  `POST /v1/api/token` - HTTP 200
    func testGetTokenFromAuthCodeSuccess() async throws {
        let client = OpenPassClient(MockNetworkSession("token-200", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.idToken, "123456789")
        XCTAssertEqual(token.accessToken, "987654321")
        XCTAssertEqual(token.tokenType, "Bearer")
        
    }

    /// 🟥  `POST /v1/api/token` - HTTP 400
    func testGetTokenFromAuthCodeBadRequestError() async throws {
        let client = OpenPassClient(MockNetworkSession("token-400", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.error, "invalid_client")
        XCTAssertEqual(token.errorDescription, "Could not find client for supplied id")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

    /// 🟥  `POST /v1/api/token` - HTTP 401
    func testGetTokenFromAuthCodeUnauthorizedUserError() async throws {
        let client = OpenPassClient(MockNetworkSession("token-401", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.error, "invalid_client")
        XCTAssertEqual(token.errorDescription, "Could not find client for supplied id")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

    /// 🟥  `POST /v1/api/token` - HTTP 500
    func testGetTokenFromAuthCodeServerError() async throws {
        let client = OpenPassClient(MockNetworkSession("token-500", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.error, "server_error")
        XCTAssertEqual(token.errorDescription, "An unexpected error has occurred")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

    /// 🟩  `POST /v1/api/uid2/generate` - HTTP 200
    func testGenerateUID2Token() async throws {
        let client = OpenPassClient(MockNetworkSession("uid2-token-200", "json"))
        
        let token = try await client.generateUID2Token(accessToken: "123456789")
                
        XCTAssertEqual(token.advertisingToken, "VGhpcyBpcyBhbiBleGFtcGxlIGFkdmVydGlzaW5nIHRva2Vu")
        XCTAssertEqual(token.identityExpires, 1665060668984)
        XCTAssertEqual(token.refreshToken, "VGhpcyBpcyBhbiBleGFtcGxlIHJlZnJlc2ggdG9rZW4=")
        XCTAssertEqual(token.refreshFrom, 1665060652250)
        XCTAssertEqual(token.refreshExpires, 1665060693879)
        XCTAssertEqual(token.refreshResponseKey, "VGhpcyBpcyBhbiBleGFtcGxlIHJlZnJlc2ggcmVzcG9uc2Uga2V5")
    }
        
    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 400
    func testGenerateUID2TokenBadRequestError() async throws {
        let client = OpenPassClient(MockNetworkSession("uid2-token-400", "json"))
        
        let token = try await client.generateUID2Token(accessToken: "123456789")

        XCTAssertEqual(token.error, "bad_request")
        XCTAssertEqual(token.errorDescription, "Authorization header is required.")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 401
    func testGenerateUID2TokenUnauthorizedError() async throws {
        let client = OpenPassClient(MockNetworkSession("uid2-token-401", "json"))
        
        let token = try await client.generateUID2Token(accessToken: "123456789")

        XCTAssertEqual(token.error, "unauthorized")
        XCTAssertEqual(token.errorDescription, "Invalid access token.")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 500
    func testGenerateUID2TokenUnexpectedError() async throws {
        let client = OpenPassClient(MockNetworkSession("uid2-token-500", "json"))
        
        let token = try await client.generateUID2Token(accessToken: "123456789")

        XCTAssertEqual(token.error, "server_error")
        XCTAssertEqual(token.errorDescription, "An unexpected error has occurred")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

}
