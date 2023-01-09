//
//  AuthenticationStateTests.swift
//  
//
//  Created by Brad Leege on 12/1/22.
//

@testable import OpenPass
import XCTest

final class OpenPassTokensTests: XCTestCase {

    func testOpenPassTokensTransformations() {
        
        let openPassTokens = OpenPassTokens(idTokenJWT: "idTokenJWT",
                             accessToken: "accessToken",
                             tokenType: "tokenType",
                            expiresIn: 86400)
        
        guard let data = try? openPassTokens.toData() else {
            XCTFail("Unable to get data from OpenPassTokens")
            return
        }

        let openPassTokensRebuilt = OpenPassTokens.fromData(data)
        XCTAssertNotNil(openPassTokensRebuilt, "AuthenticationState was not rebuilt")

        XCTAssertEqual(openPassTokensRebuilt?.idTokenJWT, "idTokenJWT", "ID Token was not rebuilt properly")
        XCTAssertEqual(openPassTokensRebuilt?.accessToken, "accessToken", "Access Token was not rebuilt properly")
        XCTAssertEqual(openPassTokensRebuilt?.tokenType, "tokenType", "Token Type was not rebuilt properly")
        XCTAssertEqual(openPassTokensRebuilt?.expiresIn, 86400, "Expires In was not rebuilt properly")
        
    }

}
