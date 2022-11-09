//
//  OpenPassClientTests.swift
//  
//
//  Created by Brad Leege on 11/7/22.
//

@testable import OpenPass
import XCTest

final class OpenPassClientTests: XCTestCase {

    func testGetTokenFromAuthCode() async throws {
        let client = OpenPassClient(MockNetworkSession("token-200", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        XCTAssertEqual(token.idToken, "123456789")
        XCTAssertEqual(token.accessToken, "987654321")
        XCTAssertEqual(token.tokenType, "Bearer")
        
    }

}
