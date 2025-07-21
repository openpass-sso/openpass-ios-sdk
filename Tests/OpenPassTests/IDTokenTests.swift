//
//  IDTokenTests.swift
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
// The above copyright notice and this permission notice shall be included in all
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

import XCTest
@testable import OpenPass

@available(iOS 13.0, tvOS 16.0, *)
final class IDTokenTests: XCTestCase {
    
    // Test JWT header: {"alg":"RS256","kid":"test-key-id","typ":"JWT"}
    private let testJWTHeader = "eyJhbGciOiJSUzI1NiIsImtpZCI6InRlc3Qta2V5LWlkIiwidHlwIjoiSldUIn0"
    
    // Test JWT signature (dummy)
    private let testJWTSignature = "test-signature"
    
    private func createJWTPayload(_ payload: [String: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: payload)
        return jsonData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func createJWT(payload: [String: Any]) -> String {
        let payloadString = createJWTPayload(payload)
        return "\(testJWTHeader).\(payloadString).\(testJWTSignature)"
    }
    
    // MARK: - Email Verified Tests
    
    func testEmailVerifiedTrue() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123",
            "aud": "client123",
            "exp": 1234567890,
            "iat": 1234567000,
            "email": "test@example.com",
            "email_verified": true,
            "given_name": "John",
            "family_name": "Doe"
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNotNil(idToken)
        XCTAssertEqual(idToken?.emailVerified, true)
        XCTAssertEqual(idToken?.email, "test@example.com")
    }
    
    func testEmailVerifiedFalse() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123",
            "aud": "client123",
            "exp": 1234567890,
            "iat": 1234567000,
            "email": "test@example.com",
            "email_verified": false,
            "given_name": "John",
            "family_name": "Doe"
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNotNil(idToken)
        XCTAssertEqual(idToken?.emailVerified, false)
        XCTAssertEqual(idToken?.email, "test@example.com")
    }
    
    func testEmailVerifiedDefaultsToTrue() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123",
            "aud": "client123",
            "exp": 1234567890,
            "iat": 1234567000,
            "email": "test@example.com",
            "given_name": "John",
            "family_name": "Doe"
            // Note: email_verified is intentionally omitted
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNotNil(idToken)
        XCTAssertEqual(idToken?.emailVerified, true, "emailVerified should default to true when not present in JWT")
        XCTAssertEqual(idToken?.email, "test@example.com")
    }
    
    func testEmailVerifiedWithoutEmail() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123",
            "aud": "client123",
            "exp": 1234567890,
            "iat": 1234567000,
            "email_verified": false
            // Note: email is intentionally omitted
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNotNil(idToken)
        XCTAssertEqual(idToken?.emailVerified, false)
        XCTAssertNil(idToken?.email)
    }
    
    // MARK: - General IDToken Tests
    
    func testValidIDTokenParsing() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123",
            "aud": "client123",
            "exp": 1234567890,
            "iat": 1234567000,
            "email": "test@example.com",
            "email_verified": true,
            "given_name": "John",
            "family_name": "Doe"
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNotNil(idToken)
        XCTAssertEqual(idToken?.keyId, "test-key-id")
        XCTAssertEqual(idToken?.tokenType, "JWT")
        XCTAssertEqual(idToken?.algorithm, "RS256")
        XCTAssertEqual(idToken?.issuerIdentifier, "https://example.com")
        XCTAssertEqual(idToken?.subjectIdentifier, "user123")
        XCTAssertEqual(idToken?.audience, "client123")
        XCTAssertEqual(idToken?.expirationTime, 1234567890)
        XCTAssertEqual(idToken?.issuedTime, 1234567000)
        XCTAssertEqual(idToken?.email, "test@example.com")
        XCTAssertEqual(idToken?.emailVerified, true)
        XCTAssertEqual(idToken?.givenName, "John")
        XCTAssertEqual(idToken?.familyName, "Doe")
    }
    
    func testInvalidJWTReturnsNil() {
        let invalidJWT = "invalid.jwt.token"
        let idToken = IDToken(idTokenJWT: invalidJWT)
        
        XCTAssertNil(idToken)
    }
    
    func testJWTWithMissingRequiredFieldsReturnsNil() {
        let payload: [String: Any] = [
            "iss": "https://example.com",
            "sub": "user123"
            // Missing required fields: aud, exp, iat
        ]
        
        let jwt = createJWT(payload: payload)
        let idToken = IDToken(idTokenJWT: jwt)
        
        XCTAssertNil(idToken)
    }
} 