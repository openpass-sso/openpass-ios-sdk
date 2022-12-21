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
        
        let oidc = OpenPassTokens(idToken: "idToken",
                             accessToken: "accessToken",
                             tokenType: "tokenType")
        let authState = AuthenticationTokens(oidcToken: oidc)
        
        guard let data = try? authState.toData() else {
            XCTFail("Unable to get data from AuthenticationState")
            return
        }

        let authStateRebuilt = AuthenticationTokens.fromData(data)
        XCTAssertNotNil(authStateRebuilt, "AuthenticationState was not rebuilt")

        XCTAssertEqual(authStateRebuilt?.oidcToken.idToken, "idToken", "ID Token was not rebuilt properly")
        XCTAssertEqual(authStateRebuilt?.oidcToken.accessToken, "accessToken", "Access Token was not rebuilt properly")
        XCTAssertEqual(authStateRebuilt?.oidcToken.tokenType, "tokenType", "Token Type was not rebuilt properly")
        
    }

}
