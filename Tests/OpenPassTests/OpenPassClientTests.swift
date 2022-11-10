//
//  OpenPassClientTests.swift
//  
//
//  Created by Brad Leege on 11/7/22.
//

@testable import OpenPass
import XCTest

final class OpenPassClientTests: XCTestCase {

    /// 🟩  `POST /v1/api/token`
    func testGetTokenFromAuthCodeSuccess() async throws {
        let client = OpenPassClient(MockNetworkSession("token-200", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.idToken, "123456789")
        XCTAssertEqual(token.accessToken, "987654321")
        XCTAssertEqual(token.tokenType, "Bearer")
        
    }

    /// 🟥  `POST /v1/api/token`
    func testGetTokenFromAuthCodeBadRequest() async throws {
        let client = OpenPassClient(MockNetworkSession("token-400", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.error, "invalid_client")
        XCTAssertEqual(token.errorDescription, "Could not find client for supplied id")
        XCTAssertEqual(token.errorUri, "https://auth.myopenpass.com")
        
    }

}
