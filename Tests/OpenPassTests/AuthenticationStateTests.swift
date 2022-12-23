//
//  AuthenticationStateTests.swift
//  
//
//  Created by Brad Leege on 12/1/22.
//

@testable import OpenPass
import XCTest

final class AuthenticationStateTests: XCTestCase {

    func testAutenticationStateTransformations() {
        
        let openPassTokens = OpenPassTokens(idTokenJWT: "idTokenJWT",
                             accessToken: "accessToken",
                             tokenType: "tokenType",
                            expiresIn: 86400)
        let authState = AuthenticationTokens(openPassTokens: openPassTokens)
        
        guard let data = try? authState.toData() else {
            XCTFail("Unable to get data from AuthenticationState")
            return
        }

        let authStateRebuilt = AuthenticationTokens.fromData(data)
        XCTAssertNotNil(authStateRebuilt, "AuthenticationState was not rebuilt")

        XCTAssertEqual(authStateRebuilt?.openPassTokens.idTokenJWT, "idTokenJWT", "ID Token was not rebuilt properly")
        XCTAssertEqual(authStateRebuilt?.openPassTokens.accessToken, "accessToken", "Access Token was not rebuilt properly")
        XCTAssertEqual(authStateRebuilt?.openPassTokens.tokenType, "tokenType", "Token Type was not rebuilt properly")
        XCTAssertEqual(authStateRebuilt?.openPassTokens.expiresIn, 86400, "Expires In was not rebuilt properly")
        
    }

}
