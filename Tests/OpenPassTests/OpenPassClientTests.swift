//
//  OpenPassClientTests.swift
//  
//
//  Created by Brad Leege on 11/7/22.
//

import XCTest
@testable import OpenPass

final class OpenPassClientTests: XCTestCase {

    func testGetTokenFromAuthCode() async throws {
        let client = OpenPassClient()

        let token = try await client.getTokenFromAuthCode(clientId: "29352915982374239857", code: "bar", redirectUri: "openpass://com.myopenpass.devapp")
    }

}
