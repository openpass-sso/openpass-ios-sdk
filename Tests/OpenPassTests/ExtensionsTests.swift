//
//  ExtensionsTests.swift
//  
//
//  Created by Brad Leege on 11/18/22.
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
