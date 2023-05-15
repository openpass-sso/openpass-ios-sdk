//
//  File.swift
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

import AuthenticationServices
import CryptoKit
import Foundation

#if os(iOS)
extension OpenPassManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
#endif

//extension OpenPassManager: ASAuthorizationControllerDelegate {
//
//    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        print("didCompleteWithAuthorization = \(authorization)")
//    }
//    
//    public func authorizationController(_ controller: ASAuthorizationController, didCompleteWithCustomMethod method: ASAuthorizationCustomMethod) {
//        print("didCompleteWithCustomMethod = \(method)")
//    }
//    
//    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("didCompleteWithError = \(error)")
//    }
//    
//}

//extension OpenPassManager: ASAuthorizationControllerPresentationContextProviding {
//    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return 
//    }
//    
//}

@available(iOS 13.0, tvOS 16.0, *)
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
