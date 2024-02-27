//
//  OpenPassManagerTests.swift
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
final class OpenPassManagerTests: XCTestCase {

    // Base64-URL Encoded String
    let codeVerifier = "2hrVVNjQL-5JuQTCqrdIgHTVIIFQnxEXGOTy1VNkuQM"

    // SHA256 digested and then Base64-URL Encoded String
    let codeChallenge = "rrw_o86gcCbS5BGxT-FUC-AoVjDyMXpRDiYjXUR0Kak"
    
    @MainActor
    func testGenerateCodeChallengeFromVerifierCode() {
        
        let generatedCodeChallenge = OpenPassManager.shared.generateCodeChallengeFromVerifierCode(verifier: codeVerifier)
        
        XCTAssertEqual(generatedCodeChallenge, codeChallenge, "Generated Code Challenge not generated correctly")
    }
    
    func testURLSchemeExtraction() {
        let urlTypes = [
            ["CFBundleURLSchemes": ["test"]],
            ["CFBundleURLSchemes": ["com.myopenpass.auth.1234"]],
        ]
        XCTAssertEqual("com.myopenpass.auth.1234", openPassRedirectScheme(urlTypes: urlTypes))

        let invalidUrlTypes = [
            ["CFBundleURLSchemes": ["com.myopenpass.invalid.1234"]],
            ["CFBundleURLSchemes": ["com.myopenpass.auth1234"]]
        ]
        XCTAssertNil(openPassRedirectScheme(urlTypes: invalidUrlTypes))
    }
}
