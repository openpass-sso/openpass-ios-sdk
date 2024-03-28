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
    
    /// 🟩  `POST /v1/api/token` - HTTP 200
    func testGetTokenFromAuthCodeSuccess() async throws {
        try HTTPStub.shared.stubAlways(fixture: "openpasstokens-200")

        let response = try await OpenPassClient.test.getTokenFromAuthCode(
            code: "bar",
            codeVerifier: "foo",
            redirectUri: "openpass://com.myopenpass.devapp"
        )
        let now = Date()
        let token = try OpenPassTokens(response, now: now)
        let idToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3NDQwODA2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.SqvXHl1hJJm1iMHko6-RUNLcBaxoYAQZlM-gmNQtLzDGV1yjSMRrCNiWOVBUL8mpEu3pw56SngBAROLMhd2JYDXfYmdM-uFS9k7DqkXucEx0BbpZdggKeDEhI3tpDkKzCmP1DkKf9QI2Q6CQXtBIDyZxuJOnhZdVeqr5hhePIoKNXGKm8Pk98wt2hxKZw_Q9oBn085CGEUmMk3Px1pQQtpPUbaZ4QBq9weZV-ebh5h8V_i8WFRM0unNHphzgt-02YtU7UHyq9BGQKGMl1SdeU18mHKHoJKfQt5y3z0PrE7wWzSeI1hCihV3S_tHagCtIHoOAm-3JColiq0d4DKdzJQ"
        
        let accessToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3MTkwMjQ2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.w20dmB-1_U613HIsLkGFrEXVxkuPqJBsRhtW4r-XhINKX3o-jsNYdHkgx6K5lAo15wPjpQ9roHN91cmN8AXSwLH6t0PMuUwprZhuBp5YnGUDF_HTU14V49_81ExZ309pQy9RfJ5NVuoE9AAg1LGYNDDkaINQmvw7Ae2NGG6_NZ7XaBxlWVyNuzrAZnATklLuOhs5brq11gzLXPzMIIUkkN-EIs2YL1WGBiBAOCQWuBSTLiJHne__MW2-ZCu9uUGbgO6Cz16Vd6iZ958QxXAgX5iNDcVBJulpgFlVf6cPpdYCqApUrM7gitV_0LhpUb2qLazX3NsI0X1glJrNMDsYfw"
        
        XCTAssertEqual(
            token,
            OpenPassTokens(
                idToken: IDToken(
                    idTokenJWT: idToken,
                    keyId: "TsQtpnYfcfZn5ePKEagh3cSYFqlgLouxEOmNXMQRQeU",
                    tokenType: "JWT",
                    algorithm: "RS256",
                    issuerIdentifier: "http://localhost:8888",
                    subjectIdentifier: "1c6309c9-beae-4c3b-9f9b-37076996d8a6",
                    audience: "29352915982374239857",
                    expirationTime: 1674408060,
                    issuedTime: 1671816060,
                    email: "foo@bar.com"
                ),
                idTokenJWT: idToken,
                idTokenExpiresIn: nil,
                accessToken: accessToken,
                tokenType: "Bearer",
                expiresIn: 86400,
                refreshToken: nil,
                refreshTokenExpiresIn: nil,
                issuedAt: now
            )
        )
    }

    /// 🟥  `POST /v1/api/token` - HTTP 400
    func testGetTokenFromAuthCodeBadRequestError() async throws {
        try HTTPStub.shared.stubAlways(fixture: "openpasstokens-400", statusCode: 400)

        let response = try await OpenPassClient.test.getTokenFromAuthCode(
            code: "bar",
            codeVerifier: "foo",
            redirectUri: "openpass://com.myopenpass.devapp"
        )
        XCTAssertEqual(
            response,
            .failure(
                OpenPassTokensResponse.Error(
                    error: "invalid_client",
                    errorDescription: "Could not find client for supplied id",
                    errorUri: "https://auth.myopenpass.com"
                )
            )
        )
    }

    /// 🟥  `POST /v1/api/token` - HTTP 401
    func testGetTokenFromAuthCodeUnauthorizedUserError() async throws {
        try HTTPStub.shared.stubAlways(fixture: "openpasstokens-401", statusCode: 401)

        let response = try await OpenPassClient.test.getTokenFromAuthCode(
            code: "bar",
            codeVerifier: "foo",
            redirectUri: "openpass://com.myopenpass.devapp"
        )
        XCTAssertEqual(
            response,
            .failure(
                OpenPassTokensResponse.Error(
                    error: "invalid_client",
                    errorDescription: "Could not find client for supplied id",
                    errorUri: "https://auth.myopenpass.com"
                )
            )
        )
    }

    /// 🟥  `POST /v1/api/token` - HTTP 500
    func testGetTokenFromAuthCodeServerError() async throws {
        try HTTPStub.shared.stubAlways(fixture: "openpasstokens-500", statusCode: 500)

        let response = try await OpenPassClient.test.getTokenFromAuthCode(
            code: "bar",
            codeVerifier: "foo",
            redirectUri: "openpass://com.myopenpass.devapp"
        )
        XCTAssertEqual(
            response,
            .failure(
                OpenPassTokensResponse.Error(
                    error: "server_error",
                    errorDescription: "An unexpected error has occurred",
                    errorUri: "https://auth.myopenpass.com"
                )
            )
        )
    }
 
    /// 🟩  `POST /v1/api/authorize-device` - HTTP 200
    func testGetDeviceCode() async throws {
        try HTTPStub.shared.stub(fixtures: ["/v1/api/authorize-device" : ("authorize-device-200", 200)])

        let deviceCode = try await OpenPassClient.test.getDeviceCode()

        XCTAssertEqual(
            deviceCode,
            DeviceAuthorizationResponse.success(.init(
                deviceCode: "BssE3cSE8tGw2wVp0Ah7agAAAAAAAAAA",
                userCode: "T4UGZ6RK",
                verificationUri: "https://auth.myopenpass.com/device",
                verificationUriComplete: "https://auth.myopenpass.com/device?user_code=T4UGZ6RK",
                expiresIn: 500,
                interval: 5
            ))
        )
    }

    /// 🟥  `POST /v1/api/authorize-device` - HTTP 400
    func testDeviceCodeError() async throws {
        try HTTPStub.shared.stub(fixtures: ["/v1/api/authorize-device" : ("authorize-device-400", 400)])

        let deviceCode = try await OpenPassClient.test.getDeviceCode()

        XCTAssertEqual(
            deviceCode,
            DeviceAuthorizationResponse.failure(.init(
                error: "invalid_scope",
                errorDescription: "Invalid scope, expecting openid", 
                errorUri: nil
            ))
        )
    }

    /// 🟩  `POST /v1/api/device-token` - HTTP 200
    func testGetTokenFromDeviceCode() async throws {
        try HTTPStub.shared.stub(fixtures: ["/v1/api/device-token" : ("openpasstokens-200", 200)])

        let token = try await OpenPassClient.test.getTokenFromDeviceCode(deviceCode: "12345")
        XCTAssertEqual(
            token,
            .success(
                OpenPassTokensResponse.Success(
                    accessToken: "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3MTkwMjQ2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.w20dmB-1_U613HIsLkGFrEXVxkuPqJBsRhtW4r-XhINKX3o-jsNYdHkgx6K5lAo15wPjpQ9roHN91cmN8AXSwLH6t0PMuUwprZhuBp5YnGUDF_HTU14V49_81ExZ309pQy9RfJ5NVuoE9AAg1LGYNDDkaINQmvw7Ae2NGG6_NZ7XaBxlWVyNuzrAZnATklLuOhs5brq11gzLXPzMIIUkkN-EIs2YL1WGBiBAOCQWuBSTLiJHne__MW2-ZCu9uUGbgO6Cz16Vd6iZ958QxXAgX5iNDcVBJulpgFlVf6cPpdYCqApUrM7gitV_0LhpUb2qLazX3NsI0X1glJrNMDsYfw",
                    tokenType: "Bearer",
                    expiresIn: 86400,
                    idToken: "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxYzYzMDljOS1iZWFlLTRjM2ItOWY5Yi0zNzA3Njk5NmQ4YTYiLCJhdWQiOiIyOTM1MjkxNTk4MjM3NDIzOTg1NyIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODg4OCIsImV4cCI6MTY3NDQwODA2MCwiaWF0IjoxNjcxODE2MDYwLCJlbWFpbCI6ImZvb0BiYXIuY29tIn0.SqvXHl1hJJm1iMHko6-RUNLcBaxoYAQZlM-gmNQtLzDGV1yjSMRrCNiWOVBUL8mpEu3pw56SngBAROLMhd2JYDXfYmdM-uFS9k7DqkXucEx0BbpZdggKeDEhI3tpDkKzCmP1DkKf9QI2Q6CQXtBIDyZxuJOnhZdVeqr5hhePIoKNXGKm8Pk98wt2hxKZw_Q9oBn085CGEUmMk3Px1pQQtpPUbaZ4QBq9weZV-ebh5h8V_i8WFRM0unNHphzgt-02YtU7UHyq9BGQKGMl1SdeU18mHKHoJKfQt5y3z0PrE7wWzSeI1hCihV3S_tHagCtIHoOAm-3JColiq0d4DKdzJQ",
                    idTokenExpiresIn: nil,
                    refreshToken: nil,
                    refreshTokenExpiresIn: nil
                )
            )
        )
    }
    
    /// 🟥  `POST /v1/api/device-token` - HTTP 400
    func testGetTokenFromDeviceCodeError() async throws {
        try HTTPStub.shared.stub(fixtures: ["/v1/api/device-token" : ("device-token-expired-token", 400)])

        let response = try await OpenPassClient.test.getTokenFromDeviceCode(deviceCode: "12345")
        XCTAssertEqual(
            response,
            .failure(
                OpenPassTokensResponse.Error(
                    error: "expired_token",
                    errorDescription: "This authorization request has expired. Please initiate a new one.",
                    errorUri: nil
                )
            )
        )
    }
}
