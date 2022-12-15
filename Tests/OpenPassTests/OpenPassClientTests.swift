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

    /*
    /// 🟩  `POST /v1/api/token` - HTTP 200
    func testGetTokenFromAuthCodeSuccess() async throws {
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("token-200", "json"))
        
        let token = try await client.getTokenFromAuthCode(clientId: "ABCDEFGHIJK",
                                                          code: "bar", codeVerifier: "foo",
                                                          redirectUri: "openpass://com.myopenpass.devapp")
        
        let idToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJ1aWQyX3J0IjoiQUFBQUFndlNzMEtXYzgrbUkxaTMrd0srZ05zV21LeTRsRHJndzYxampkaGtsdVN3MjJzNUpWbVJZYUoxRVZjUHdodWV0b3pqd1lmd2gyNlRFcS9wYjRuNDNsNTNoSGNsSmxSQUVjYXAvTGd0VVdnUXN5S1NVbmZXb3ZMWllPc2R6SVJqSmM3RS9KeW5ZTlpFaUpmSzZRZlY2K2xUcGFnaHYxZTRTK1VEVXNjMzg0RlRZVGlIcHpHOS9ZWTJOcnFtRldWQ3FjbXVGbG1PUmF5dXRid3FkRzhEVVoyaDhYN3d1K0xtYkprU29JNjM4SzZoVXJIb2ozdXlZaC9tRUFXQTA3d3oweFZUbFNWOVNhSVppNUQ1U1Z4Qy9Ra2p5TndjWCtRdEVWTUo2Z00vRjlZd0ZuaU5zdkZKVWRUeGNseEt2OFJLZHRPUzRJU2IyNGxNVEFzWjl6Zm1HUUtMM0dOczVJSVFZR3VJZEhLczNGQUpKeXpSUnVXMEJWeERnNE9ZOVJQViIsInN1YiI6ImZvb0BiYXIuY29tIiwiYXVkIjoiMjkzNTI5MTU5ODIzNzQyMzk4NTciLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgiLCJ1aWQyX3JrZXkiOiIrV0VMbUF0enN0aksyb2hNejR2c0pyTTJNSWJhU1ozRUFnQjhFVjYvc0hjPSIsInVpZDJfcmV4cCI6MTY3MzEwMDE1ODU2MSwiZXhwIjoxNjczMTAwMTU4LCJpYXQiOjE2NzA1MDgxNTgsInVpZDJfcmZyb20iOjE2NzA1MDg0NTg1NjEsInVpZDJfaWV4cCI6MTY3MDUwOTA1ODU2MSwidWlkMl9hdCI6IkFnQUFBZ3FLQXl4RS8yNE5tYlFEOFFoTWR4RmVKd2dkUjhmTmo4b2hNM2lQeDhZcWxLV1crdmRCZ1Y4NWVOcEhFclh2aTZKOWM0Y0QrSlJUTVFaSHVGT3QxNis4c2tucno4eFQwa3hocmlITmtmeW92QS8xR01QcTJINGJJbmFnOGRDeGtDVEFyQ2RnTkYvV1BZWlNYRStBK3YzNU5yblRQNE5RaVFiakh4aUNwNnU2YkE9PSJ9.xGv69IYZOt9wsoxlIL9_UwqsLnEwwjS2UN_ogFOIEdYqu_BI29N2WwjoeUyHUbEJtdzA4DGvkEXufg5OOijc8wSZnNKVlogwoHqGn6bh5azyaSpTcsbKRg4uNO3veJsGzAB_JDqtF0tt1ShRNClleArl7zB9GxlkWO70JBKw9ZcPMSAFQ-PsgzyNPjkRvGvEMCRqtxuhkKIYS0NjygOElAS-oVt89r3zLoJReEKH-Cu9Ul0j5PXke3Ku5WJnyWlPs8w1u8JSBo_6tqMeteur6bdGrp_9MuxPBmgLV3Q4kpJm_jfExy_d8YWgqMAPoX_WMJs9yITTEEcwfzWrn2BC0w"
        
        let accessToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJmb29AYmFyLmNvbSIsImF1ZCI6IjI5MzUyOTE1OTgyMzc0MjM5ODU3IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4IiwiZXhwIjoxNjcwNTA4NzU4LCJpYXQiOjE2NzA1MDgxNTh9.LBNyIosd-6Hrw4OxsRrf_fMeTslRzIzFqVWqHCZoZzYs-Rm2m8AzYJ1EOxvYoPtS5fJ15kh_mxQcl1UDHtZYjVEgnXlEjZ74P4eCRrSGLde1RRuu6G0Re9xL7Ofd-iErxJH8K9QOVqSdZ6uBOAXJzi4zdZKiWi4DWS-MbemnN8g7uhf-oQWOxLCR_z0_bgatyTO2em-GFkYvLM5qgAKb2rWcfuRfauzOy0qI6bF8zHCiFRtGlbfVxaGUBrBf8Y0LFZtMoXkoP8CNvNTErBXV5jjkZwWLA5L8iYG6Q93-mUF365SlHbztuZZfxKgtM97VBu7RssflaRYPkc1h4j6hCQ"
        
        XCTAssertEqual(token.idToken, idToken)
        XCTAssertEqual(token.accessToken, accessToken)
        XCTAssertEqual(token.tokenType, "Bearer")
        
    }
*/
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

    @MainActor
    func testValidateOIDCToken() async throws {
        
        let client = OpenPassClient(authAPIUrl: "", MockNetworkSession("jwks", "json"))
        
        guard let bundlePath = Bundle.module.path(forResource: "token-200", ofType: "json", inDirectory: "TestData"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
            throw "Could not load JSON from file."
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let oidcTokenResponse = try decoder.decode(APIOIDCTokenResponse.self, from: jsonData)
        
        guard let oidcToken = oidcTokenResponse.toOIDCToken() else {
            XCTFail("Unable to convert to OIDCToken")
            return
        }
        
        let verificationResult = try await client.verifyOIDCToken(oidcToken)
        
        XCTAssertEqual(verificationResult, true, "JWT was not validated")
    }
    
}
