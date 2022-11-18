//
//  File.swift
//  
//
//  Created by Brad Leege on 10/21/22.
//

import AuthenticationServices
import CryptoKit
import Foundation

extension OpenPassManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

extension OpenPassManager {
    
    func generateCodeChallengeFromVerifierCode(verifier: String) -> String {
        
        let codeVerifierData = Data(verifier.utf8)
        let challengeHash = SHA256.hash(data: codeVerifierData)
        
        // Need to get challengeHash to Data and THEN baseURLEncode
        let bytes: [UInt8] = Array(challengeHash.makeIterator())
        let data: Data = Data(bytes)
        let base64UrlEncodedHashed = data.base64EncodedString().base64URLEscaped()

        return base64UrlEncodedHashed
    }

}
