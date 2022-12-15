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
        
        let idToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJ1aWQyX3J0IjoiQUFBQUFnODVBYjlkUzRjekhwUjVnL2NuT2x5UnVmd2FRWkk4bUkwL2NJcjdONEZEcmdxK2NUeEFFaDNVVlpBVllYQUxzM1RsZWFhUi9TMzVwNmNza1dNQ1Z0eXFGMDM1djkwQkVERC94WkI3UDc0b0FHckczMW5BVS9LYkYwakNrdzk1ZmlUVXZwV29kdXFpcjRrb2UvaEUrMjcrTS9EVjNEaWZqaUMwdUVDTWUxZENnc3dMekhaYmZKMGs3L0tuNE5aazQya2lqeUtPSHNCNkVNd2RnYWVlNkxYbWpUUk5zaEpqODB3cUUvcXcvcWtSUHJwMWswVTlzazMzVi9vMGFwMzRVcU5IbmVBZ0M1S0ZtWGQ4VGRKbGd6TlprbHZGSHJMS3RWWHhTZGRaQzNnTFdhM0VkT2RLa0k1alNsRlM5d0FDalBPNkZ1QVl0cW5TS1F5VUZUZVY2dFU1Y0hVNHJaUFVhMmoxbTFqSXloZjR4NVd3M3J2VmNHQTg2dFd1a0QraiIsInN1YiI6ImZvb0BiYXIuY29tIiwiYXVkIjoiMjkzNTI5MTU5ODIzNzQyMzk4NTciLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgiLCJ1aWQyX3JrZXkiOiJhVXV3bUhRcTNmcVVaOU9KdENKZU1mQjdEZHBZaTZnRVNpSVdic2xyWFpRPSIsInVpZDJfcmV4cCI6MTY3MzU0MjE4MzE3NCwiZXhwIjoxNjczNTQyMTgzLCJpYXQiOjE2NzA5NTAxODMsInVpZDJfcmZyb20iOjE2NzA5NTA0ODMxNzQsImVtYWlsIjoiZm9vQGJhci5jb20iLCJ1aWQyX2lleHAiOjE2NzA5NTEwODMxNzQsInVpZDJfYXQiOiJBZ0FBQWc0VncwOWNzVlVDSE0zWXpCOWtMY3BtYnpvNW50SFJVQ2NuOXVFOXk5L2ZQaHhSa3JqUnJvYVBSRGFRL0pIcE5kSjBSSzZVa0pYMGowYnNIeVkzWDNnSEZyRTZzUkR3WU53amFaajJVTFdISnZLekpQU05xTStYUjNoaFV5Y3JzSUgxSEpYT1ZubFg1Nkl2QlZYM0wwUkowS25xTkVPZnk2ZDRRaGduMHBhMlFBPT0ifQ.hP54LCgPO0cMew311k9w171o6QUEk3QUL08rdF2epYjsP0bfY8u-U6qTizIMGaxUwkmAj3h1KYZ0xQl_hKOo3gQQ7CrxJhn9vC--C-0Fi9APXSgyH0Smi1Ib1Gv55cLywYSltXiMzp6qZXLUjURB8J4919Eq18TUzhE1esnRxtUr2bE9BKIGU-aEargXCxJbDq0AYTYfr0WQESPL8RiDN0Mrr_Q-5UdCaGiDuCGG6pdg3hAW6EMB0NcORglLtw3dYDQuIPaA0JmFMXzrSU9C6il-AyDJKwOQ9EgCN9ikmi1Lodb-zyquIuCjKjnkw9rWHCBK-ZQJeqgUkPHZiWMOtQ"
        
        let accessToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJmb29AYmFyLmNvbSIsImF1ZCI6IjI5MzUyOTE1OTgyMzc0MjM5ODU3IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4IiwiZXhwIjoxNjcwNTA4NzU4LCJpYXQiOjE2NzA1MDgxNTh9.LBNyIosd-6Hrw4OxsRrf_fMeTslRzIzFqVWqHCZoZzYs-Rm2m8AzYJ1EOxvYoPtS5fJ15kh_mxQcl1UDHtZYjVEgnXlEjZ74P4eCRrSGLde1RRuu6G0Re9xL7Ofd-iErxJH8K9QOVqSdZ6uBOAXJzi4zdZKiWi4DWS-MbemnN8g7uhf-oQWOxLCR_z0_bgatyTO2em-GFkYvLM5qgAKb2rWcfuRfauzOy0qI6bF8zHCiFRtGlbfVxaGUBrBf8Y0LFZtMoXkoP8CNvNTErBXV5jjkZwWLA5L8iYG6Q93-mUF365SlHbztuZZfxKgtM97VBu7RssflaRYPkc1h4j6hCQ"
        
        XCTAssertEqual(token.idToken, idToken)
        XCTAssertEqual(token.accessToken, accessToken)
        XCTAssertEqual(token.tokenType, "Bearer")
        
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
