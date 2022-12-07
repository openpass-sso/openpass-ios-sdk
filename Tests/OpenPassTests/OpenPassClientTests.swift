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
        
        let idToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJ1aWQyX3J0IjoiQUFBQUFnZ3cxaUcrL1o0OGJ3aW9IMitRZGhkbHdQbHV6ak92RWM5UkVjdURHc0ZiNE9PL09ObUZ0bkR3NEwzbDlVSWdVMjZrQkdEUlF4dWlaQjl0SEFIWmdtSGs0Z3Vza2VDQ3ptQ25maWw5cU5IRmE0MU9vZHo1bE5vZmNDeUxXSVJ6bm44bHB1Ulpob0NHcnNiYUxTYWVITzMvMXhJeGN6UlB3MDRXVUFpUnpaSWVzcWhQOU1XNC8rK2R1UnAzZFhxd0RGbmZTaXJLYlpqaXRYNFFiVGxtelQ3b3lnZ1VlQld1emxnYVkvQzJXWnRmVXVVaGN3aGM1WU1MbE8xWkhHUkFnSjZyK1ZjSGU5NUtuT29NWCs5ZmdnMXFIWGhFbm5wa1JWb0J1MEN3TkdlNkMrYkVpNHhyZklOT015YXA5ZmU1RWZtaTZjZmZmdENVdjNWNkdXdk9vaStyandjcnJBOEdPMkpoYUtpS2hXWThuTTJ6alFHTW4rSlFZRnZSaDFkMSIsInN1YiI6ImZvb0BiYXIuY29tIiwiYXVkIjoiMjkzNTI5MTU5ODIzNzQyMzk4NTciLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0Ojg4ODgiLCJ1aWQyX3JrZXkiOiJzTGJ2RWlWMXN4TU1VdXdYTi80Ui9LUi96VllEUmZ5SEY3WVpGTiswTmlJPSIsInVpZDJfcmV4cCI6MTY3MzAxOTYxMTQxNiwiZXhwIjoxNjczMDE5NjA5LCJpYXQiOjE2NzA0Mjc2MDksInVpZDJfcmZyb20iOjE2NzA0Mjc5MTE0MTYsInVpZDJfaWV4cCI6MTY3MDQyODUxMTQxNiwidWlkMl9hdCI6IkFnQUFBZ2Uzd0FJL1RobEtkZ2tncVY0"
        
        let accessToken = "eyJraWQiOiJUc1F0cG5ZZmNmWm41ZVBLRWFnaDNjU1lGcWxnTG91eEVPbU5YTVFSUWVVIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJmb29AYmFyLmNvbSIsImF1ZCI6IjI5MzUyOTE1OTgyMzc0MjM5ODU3IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4ODg4IiwiZXhwIjoxNjcwNDI4MjA5LCJpYXQiOjE2NzA0Mjc2MDl9.ifvDROOTDcVQWoitEBqOnXiDqQ6MTQ5_6pgoFDZJdsJkMJxo1wX41z6LY_F3lDp-EmXq8JhcSTRDbnTD8R3weHngSUm_McwLajjtM_Rbueoi1lPXoQr_lgt0zTeWR1POTqegvf9cZ24A2aLq30w0YETeC5KgM7-k7iUZnDyVtnAiCt71FxKkJK_X-hOW22mk-d9d9EJJePuVyzjjNj5KVtIN-A0CVDyg4i7nfX5wbA8mnmUysIPSVREn31iWuBlZ5WZSzZkdunrP5BnX1_OItPUDdD7MWQp3yy8QzrmJk40rABk1xbITLFJXh7DBLkNwMPXYS-Cv-dChRRNqsK5aXA"
        
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

}
