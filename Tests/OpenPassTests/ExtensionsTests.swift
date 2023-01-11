//
//  ExtensionsTests.swift
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

import CryptoKit
@testable import OpenPass
import XCTest

final class ExtensionsTests: XCTestCase {

    // Base64-URL Encoded String
    let codeVerifier = "2hrVVNjQL-5JuQTCqrdIgHTVIIFQnxEXGOTy1VNkuQM"

    // SHA256 digested and then Base64-URL Encoded String
    let codeChallenge = "rrw_o86gcCbS5BGxT-FUC-AoVjDyMXpRDiYjXUR0Kak"
    
    // SHA256 digested and then Base64 (not URL) Encoded String
    let codeChallengeOnlyBase64Encoded = "rrw/o86gcCbS5BGxT+FUC+AoVjDyMXpRDiYjXUR0Kak="

    func testBase64URLEncodedString() {

        let codeVerifierData = Data(codeVerifier.utf8)
        let challengeHash = SHA256.hash(data: codeVerifierData)
        let bytes: [UInt8] = Array(challengeHash.makeIterator())
        let data: Data = Data(bytes)
        let base64UrlEncodedHashed = data.base64EncodedString()

        XCTAssertEqual(codeChallengeOnlyBase64Encoded, base64UrlEncodedHashed, "Data to base64UrlEncodedString failed")
    }
    
    func testBase64URLEscaped() {
        
        let test = codeChallengeOnlyBase64Encoded.base64URLEscaped()
        
        XCTAssertEqual(codeChallenge, test, "Base64URLEscaped test failed")
    }
    
}
