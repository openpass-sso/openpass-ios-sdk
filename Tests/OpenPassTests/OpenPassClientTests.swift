//
//  OpenPassClientTests.swift
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

@available(iOS 13.0, *)
final class OpenPassClientTests: XCTestCase {
    
    private let baseRequestParameters = BaseRequestParameters(sdkName: "OpenPassTest", sdkVersion: "TEST")

    /// 🟩  `POST /v1/api/token` - HTTP 200
    func testGetTokenFromAuthCodeSuccess() async throws {
        let client = OpenPassClient(baseURL: "", baseRequestParameters: baseRequestParameters, MockNetworkSession("openpasstokens-200", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar", codeVerifier: "foo",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        let idToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3NDQwODA2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.SqvXHl1hJJm1iMHko6-RUNLcBaxoYAQZlM-gmNQtLzDGV1yjSMRrCNiWOVBUL8mpEu3pw56SngBAROLMhd2JYDXfYmdM-uFS9k7DqkXucEx0BbpZdggKeDEhI3tpDkKzCmP1DkKf9QI2Q6CQXtBIDyZxuJOnhZdVeqr5hhePIoKNXGKm8Pk98wt2hxKZw_Q9oBn085CGEUmMk3Px1pQQtpPUbaZ4QBq9weZV-ebh5h8V_i8WFRM0unNHphzgt-02YtU7UHyq9BGQKGMl1SdeU18mHKHoJKfQt5y3z0PrE7wWzSeI1hCihV3S_tHagCtIHoOAm-3JColiq0d4DKdzJQ"
        
        let accessToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3MTkwMjQ2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.w20dmB-1_U613HIsLkGFrEXVxkuPqJBsRhtW4r-XhINKX3o-jsNYdHkgx6K5lAo15wPjpQ9roHN91cmN8AXSwLH6t0PMuUwprZhuBp5YnGUDF_HTU14V49_81ExZ309pQy9RfJ5NVuoE9AAg1LGYNDDkaINQmvw7Ae2NGG6_NZ7XaBxlWVyNuzrAZnATklLuOhs5brq11gzLXPzMIIUkkN-EIs2YL1WGBiBAOCQWuBSTLiJHne__MW2-ZCu9uUGbgO6Cz16Vd6iZ958QxXAgX5iNDcVBJulpgFlVf6cPpdYCqApUrM7gitV_0LhpUb2qLazX3NsI0X1glJrNMDsYfw"
        
        XCTAssertEqual(token.idTokenJWT, idToken)
        XCTAssertEqual(token.accessToken, accessToken)
        XCTAssertEqual(token.tokenType, "Bearer")
        XCTAssertEqual(token.expiresIn, 86400)

        XCTAssertNotNil(token.idToken)

        XCTAssertEqual(token.idToken?.issuerIdentifier, "http://localhost:8888")
        XCTAssertEqual(token.idToken?.subjectIdentifier, "1c6309c9-beae-4c3b-9f9b-37076996d8a6")
        XCTAssertEqual(token.idToken?.audience, "29352915982374239857")
        XCTAssertEqual(token.idToken?.expirationTime, 1674408060)
        XCTAssertEqual(token.idToken?.issuedTime, 1671816060)

        XCTAssertEqual(token.idToken?.email, "foo@bar.com")
    }

    /// 🟥  `POST /v1/api/token` - HTTP 400
    func testGetTokenFromAuthCodeBadRequestError() async {
        let client = OpenPassClient(baseURL: "",  baseRequestParameters: baseRequestParameters, MockNetworkSession("openpasstokens-400", "json"))
        
        do {
            _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                              code: "bar", codeVerifier: "foo",
                                                              redirectUri: "openpass://com.myopenpass.devapp")
        } catch {
            guard let error = error as? OpenPassError else {
                XCTFail("Error was not an OpenPassError")
                return
            }
            
            switch error {
            case let .tokenData(name, description, uri):
                XCTAssertEqual(name, "invalid_client")
                XCTAssertEqual(description, "Could not find client for supplied id")
                XCTAssertEqual(uri, "https://auth.myopenpass.com")
            default:
                XCTFail("OpenPassError non expected type")
            }
        }
    }

    /// 🟥  `POST /v1/api/token` - HTTP 401
    func testGetTokenFromAuthCodeUnauthorizedUserError() async {
        let client = OpenPassClient(baseURL: "",  baseRequestParameters: baseRequestParameters, MockNetworkSession("openpasstokens-401", "json"))

        do {
            _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                              code: "bar", codeVerifier: "foo",
                                                              redirectUri: "openpass://com.myopenpass.devapp")
        } catch {
            guard let error = error as? OpenPassError else {
                XCTFail("Error was not an OpenPassError")
                return
            }
            
            switch error {
            case let .tokenData(name, description, uri):
                XCTAssertEqual(name, "invalid_client")
                XCTAssertEqual(description, "Could not find client for supplied id")
                XCTAssertEqual(uri, "https://auth.myopenpass.com")
            default:
                XCTFail("OpenPassError non expected type")
            }
        }
    }

    /// 🟥  `POST /v1/api/token` - HTTP 500
    func testGetTokenFromAuthCodeServerError() async throws {
        let client = OpenPassClient(baseURL: "",  baseRequestParameters: baseRequestParameters, MockNetworkSession("openpasstokens-500", "json"))
        
        do {
            _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                              code: "bar", codeVerifier: "foo",
                                                              redirectUri: "openpass://com.myopenpass.devapp")
        } catch {
            guard let error = error as? OpenPassError else {
                XCTFail("Error was not an OpenPassError")
                return
            }
            
            switch error {
            case let .tokenData(name, description, uri):
                XCTAssertEqual(name, "server_error")
                XCTAssertEqual(description, "An unexpected error has occurred")
                XCTAssertEqual(uri, "https://auth.myopenpass.com")
            default:
                XCTFail("OpenPassError non expected type")
            }
        }
    }

    /// 🟩 Verify that ID Token was signed as expected
    @MainActor
    func testValidateOpenPassTokens() async throws {
        
        let client = OpenPassClient(baseURL: "",  baseRequestParameters: baseRequestParameters, MockNetworkSession("jwks", "json"))
        
        guard let bundlePath = Bundle.module.path(forResource: "openpasstokens-200", ofType: "json", inDirectory: "TestData"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
            throw "Could not load JSON from file."
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let openPassTokensResponse = try decoder.decode(OpenPassTokensResponse.self, from: jsonData)
        
        guard let openPassTokens = openPassTokensResponse.toOpenPassTokens(), let idToken = openPassTokens.idToken else {
            throw "Unable to convert to OpenPassTokens"
        }
        
        // Post Issued Time Test
        let verifiableTime = idToken.issuedTime + 50
        let verificationResult = try await client.verifyIDToken(openPassTokens, verifiableTime)
        XCTAssertEqual(verificationResult, true, "JWT was not validated")
        
        // Clock Drift Too Early For Issued Time
        let preIssued = idToken.issuedTime - 150000
        let verificationResultPreIssued = try await client.verifyIDToken(openPassTokens, preIssued)
        XCTAssertEqual(verificationResultPreIssued, false, "JWT was validated when it should not have been")
        
        // Token Expired Test
        let expiredNow = idToken.expirationTime + 5000
        let verificationResultExpired = try await client.verifyIDToken(openPassTokens, expiredNow)
        XCTAssertEqual(verificationResultExpired, false, "JWT was validated when it should not have been")
        
    }
 
    /// 🟩  `POST /v1/api/authorize-device` - HTTP 200
    func testGetDeviceCode() async throws {
        let client = OpenPassClient(baseURL: "", baseRequestParameters: baseRequestParameters, MockNetworkSession("devicecode-200", "json"))

        let deviceCode = try await client.getDeviceCode(clientId: "TESTCLIENT")
        
        XCTAssertEqual(deviceCode.deviceCode, "BssE3cSE8tGw2wVp0Ah7agAAAAAAAAAA")
        XCTAssertEqual(deviceCode.userCode, "T4UGZ6RK")
        XCTAssertEqual(deviceCode.verificationUri, "https://auth.myopenpass.com/device")
        XCTAssertEqual(deviceCode.verificationUriComplete, "https://auth.myopenpass.com/device?user_code=T4UGZ6RK")
        XCTAssertEqual(deviceCode.expiresIn, 500)
        XCTAssertEqual(deviceCode.interval, 5)
        XCTAssertNil(deviceCode.error)
        XCTAssertNil(deviceCode.errorDescription)
        
    }

    /// 🟥  `POST /v1/api/authorize-device` - HTTP 400
    func testDeviceCodeError() async throws {
        let client = OpenPassClient(baseURL: "", baseRequestParameters: baseRequestParameters, MockNetworkSession("devicecode-400", "json"))

        let deviceCode = try await client.getDeviceCode(clientId: "TESTCLIENT")

        XCTAssertEqual(deviceCode.error, "invalid_scope")
        XCTAssertEqual(deviceCode.errorDescription, "Invalid scope, expecting openid")
        
        XCTAssertNil(deviceCode.deviceCode)
        XCTAssertNil(deviceCode.userCode)
        XCTAssertNil(deviceCode.verificationUri)
        XCTAssertNil(deviceCode.verificationUriComplete)
        XCTAssertNil(deviceCode.expiresIn)
        XCTAssertNil(deviceCode.interval)
        
    }
    
}
