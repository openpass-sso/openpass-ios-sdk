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

@available(iOS 13.0, tvOS 16.0, *)
extension OpenPassManager {
    
    /// Create Code Challenge for `api/authorize` call
    /// - Parameter verifier: Locally generated verifier
    /// - Returns: Generated Code Challenge
    internal func generateCodeChallengeFromVerifierCode(verifier: String) -> String {
        
        let codeVerifierData = Data(verifier.utf8)
        let challengeHash = SHA256.hash(data: codeVerifierData)
        
        // Need to get challengeHash to Data and THEN baseURLEncode
        let bytes: [UInt8] = Array(challengeHash.makeIterator())
        let data: Data = Data(bytes)
        let base64UrlEncodedHashed = data.base64EncodedString().base64URLEscaped()

        return base64UrlEncodedHashed
    }

}
