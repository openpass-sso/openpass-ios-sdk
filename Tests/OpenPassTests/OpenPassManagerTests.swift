//
//  OpenPassManagerTests.swift
//  
//
//  Created by Brad Leege on 10/13/22.
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
        
        let generatedCodeChallenge = OpenPassManager.main.generateCodeChallengeFromVerifierCode(verifier: codeVerifier)
        
        XCTAssertEqual(generatedCodeChallenge, codeChallenge, "Generated Code Challenge not generated correctly")
    }
    
}
