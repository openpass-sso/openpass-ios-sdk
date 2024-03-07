//
//  AuthenticationStateTests.swift
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
//The above copyright notice and this permission notice shall be included in all
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

final class OpenPassTokensTests: XCTestCase {

    func testOpenPassTokensTransformations() {
        let openPassTokens = OpenPassTokens(
            idTokenJWT: "idTokenJWT",
            accessToken: "accessToken",
            tokenType: "tokenType",
            expiresIn: 86400,
            refreshToken: nil,
            refreshTokenExpiresIn: nil
        )
        
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

    func testOpenpassTokensFromResponse() throws {
        let response = try FixtureLoader.decode(OpenPassTokensResponse.self, fixture: "openpasstokens-401")
        XCTAssertThrowsError(try OpenPassTokens(response)) {
            error in
            let error = try? XCTUnwrap(error as? OpenPassError)
            XCTAssertEqual(
                error,
                .tokenData(
                    name: "invalid_client",
                    description: "Could not find client for supplied id",
                    uri: "https://auth.myopenpass.com"
                )
            )
        }
    }

}
