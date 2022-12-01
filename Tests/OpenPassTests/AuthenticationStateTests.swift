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
        
        let oidc = OIDCToken(idToken: "idToken", accessToken: "accessToken", tokenType: "tokenType")
        let uid2 = UID2Token(advertisingToken: "advertisingToken", identityExpires: 1234, refreshToken: "refreshToken", refreshFrom: 5678, refreshExpires: 9012, refreshResponseKey: "refreshResponseKey")
        let authState = AuthenticationState(authorizeCode: "authorizeCode", authorizeState: "authorizeState", oidcToken: oidc, uid2Token: uid2)
        
        guard let data = try? authState.toData() else {
            XCTFail("Unable to get data from AuthenticationState")
            return
        }

        let authStateRebuilt = AuthenticationState.fromData(data)
        XCTAssertNotNil(authStateRebuilt, "AuthenticationState was not rebuilt")

        XCTAssertEqual(authStateRebuilt?.authorizeCode, "authorizeCode")
        XCTAssertEqual(authStateRebuilt?.authorizeState, "authorizeState")
        
    }

}
