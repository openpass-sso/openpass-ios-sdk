//
//  OpenPassClientTests.swift
//  
//
//  Created by Brad Leege on 11/7/22.
//

@testable import OpenPass
import XCTest

@available(iOS 13.0, *)
final class OpenPassClientTests: XCTestCase {

    /// 🟩  `POST /v1/api/token` - HTTP 200
    func testGetTokenFromAuthCodeSuccess() async throws {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-200", "json"))
        
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

        XCTAssertEqual(token.idToken?.iss, "http://localhost:8888")
        XCTAssertEqual(token.idToken?.sub, "1c6309c9-beae-4c3b-9f9b-37076996d8a6")
        XCTAssertEqual(token.idToken?.aud, "29352915982374239857")
        XCTAssertEqual(token.idToken?.exp, 1674408060)
        XCTAssertEqual(token.idToken?.iat, 1671816060)
        
        XCTAssertNil(token.idToken?.authTime)
        XCTAssertNil(token.idToken?.nonce)
        XCTAssertNil(token.idToken?.acr)
        XCTAssertNil(token.idToken?.amr)
        XCTAssertNil(token.idToken?.azp)

        XCTAssertEqual(token.idToken?.email, "foo@bar.com")
    }

    /// 🟥  `POST /v1/api/token` - HTTP 400
    func testGetTokenFromAuthCodeBadRequestError() async {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-400", "json"))
        
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
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-401", "json"))

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
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-500", "json"))
        
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
        
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("jwks", "json"))
        
        guard let bundlePath = Bundle.module.path(forResource: "token-200", ofType: "json", inDirectory: "TestData"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
            throw "Could not load JSON from file."
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let openPassTokensResponse = try decoder.decode(OpenPassTokensResponse.self, from: jsonData)
        
        guard let openPassTokens = openPassTokensResponse.toOpenPassTokens() else {
            XCTFail("Unable to convert to OpenPassTokens")
            return
        }
        
        let verificationResult = try await client.verifyIDToken(openPassTokens)
        
        XCTAssertEqual(verificationResult, true, "JWT was not validated")
    }
 
    /// 🟩  `POST /v1/api/uid2/generate` - HTTP 200
    func testGenerateUID2Token() async {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("uid2-token-200", "json"))
        
        do {
            let token = try await client.generateUID2Token(accessToken: "123456789")
            XCTAssertEqual(token.advertisingToken, "VGhpcyBpcyBhbiBleGFtcGxlIGFkdmVydGlzaW5nIHRva2Vu")
            XCTAssertEqual(token.identityExpires, 1665060668984)
            XCTAssertEqual(token.refreshToken, "VGhpcyBpcyBhbiBleGFtcGxlIHJlZnJlc2ggdG9rZW4=")
            XCTAssertEqual(token.refreshFrom, 1665060652250)
            XCTAssertEqual(token.refreshExpires, 1665060693879)
            XCTAssertEqual(token.refreshResponseKey, "VGhpcyBpcyBhbiBleGFtcGxlIHJlZnJlc2ggcmVzcG9uc2Uga2V5")
        } catch {
            XCTFail("GenerateUID2Token endpoint threw an error when it should not have.")
        }
                
    }
        
    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 400
    func testGenerateUID2TokenBadRequestError() async throws {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("uid2-token-400", "json"))
        
        do {
            _ = try await client.generateUID2Token(accessToken: "123456789")
        } catch {
            guard let error = error as? OpenPassError else {
                XCTFail("Error was not an OpenPassError")
                return
            }
            
            switch error {
            case let .tokenData(name, description, uri):
                XCTAssertEqual(name, "bad_request")
                XCTAssertEqual(description, "Authorization header is required.")
                XCTAssertEqual(uri, "https://auth.myopenpass.com")
            default:
                XCTFail("OpenPassError non expected type")
            }
        }
    }

    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 401
    func testGenerateUID2TokenUnauthorizedError() async throws {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("uid2-token-401", "json"))
        
        do {
            _ = try await client.generateUID2Token(accessToken: "123456789")
        } catch {
            guard let error = error as? OpenPassError else {
                XCTFail("Error was not an OpenPassError")
                return
            }
            
            switch error {
            case let .tokenData(name, description, uri):
                XCTAssertEqual(name, "unauthorized")
                XCTAssertEqual(description, "Invalid access token.")
                XCTAssertEqual(uri, "https://auth.myopenpass.com")
            default:
                XCTFail("OpenPassError non expected type")
            }
        }
    }

    /// 🟥  `POST /v1/api/uid2/generate` - HTTP 500
    func testGenerateUID2TokenUnexpectedError() async throws {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("uid2-token-500", "json"))
        
        do {
            _ = try await client.generateUID2Token(accessToken: "123456789")
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
    
}
