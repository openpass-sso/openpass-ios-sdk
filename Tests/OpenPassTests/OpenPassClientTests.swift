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
        
        XCTAssertEqual(token.idToken, "123456789")
        XCTAssertEqual(token.accessToken, "987654321")
        XCTAssertEqual(token.tokenType, "Bearer")
        
    }

    /// 🟥  `POST /v1/api/token` - HTTP 400
    func testGetTokenFromAuthCodeBadRequestError() async {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-400", "json"))
        
        do {
            let _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
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
            let _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
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
            let _ = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
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
            let token = try await client.generateUID2Token(accessToken: "123456789")
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
            let token = try await client.generateUID2Token(accessToken: "123456789")
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
            let token = try await client.generateUID2Token(accessToken: "123456789")
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
