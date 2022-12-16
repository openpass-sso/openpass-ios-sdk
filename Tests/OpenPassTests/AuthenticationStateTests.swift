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
        
        let oidc = OIDCToken(idToken: "idToken",
                             accessToken: "accessToken",
                             tokenType: "tokenType")
        let authState = AuthenticationTokens(authorizeCode: "authorizeCode",
                                            authorizeState: "authorizeState",
                                            oidcToken: oidc)
        
        guard let data = try? authState.toData() else {
            XCTFail("Unable to get data from AuthenticationState")
            return
        }

        let authStateRebuilt = AuthenticationTokens.fromData(data)
        XCTAssertNotNil(authStateRebuilt, "AuthenticationState was not rebuilt")

        XCTAssertEqual(authStateRebuilt?.authorizeCode, "authorizeCode")
        XCTAssertEqual(authStateRebuilt?.authorizeState, "authorizeState")
        
    }

}
