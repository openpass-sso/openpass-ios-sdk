//
//  OpenPassTokensResponse.swift
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

import Foundation

/// Transfer data object for processing response from `/v1/api/token`
internal struct OpenPassTokensResponse: Codable {
    
    let idToken: String?
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int64?
    let error: String?
    let errorDescription: String?
    let errorUri: String?
        
    func toOpenPassTokens() -> OpenPassTokens? {
        
        guard let idToken = idToken, let accessToken = accessToken, let tokenType = tokenType, let expiresIn = expiresIn else {
            return nil
        }
        
        return OpenPassTokens(idTokenJWT: idToken, accessToken: accessToken, tokenType: tokenType, expiresIn: expiresIn)
    }
    
}
