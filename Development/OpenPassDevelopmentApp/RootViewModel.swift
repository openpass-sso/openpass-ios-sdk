//
//  RootViewModel.swift
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
import OpenPass
import SwiftUI

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = LocalizedStringKey("common.openpasssdk")
    @Published private(set) var openPassTokens: OpenPassTokens?
    @Published private(set) var error: Error?
        
    // MARK: - Display Data Formatters
    
    var idJWTToken: String {
        if let token = openPassTokens?.idTokenJWT {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var accessToken: String {
        if let token = openPassTokens?.accessToken {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var tokenType: String {
        if let token = openPassTokens?.tokenType {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var expiresIn: String {
        if let token = openPassTokens?.expiresIn {
            return String(token)
        }
        return NSLocalizedString("common.nil", comment: "")
    }

    var email: String {
        if let email = openPassTokens?.idToken?.email {
            return email
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    // MARK: - UX Flows
    
    public func startSignInUXFlow() {
        
        Task(priority: .userInitiated) {
            do {
                try await OpenPassManager.main.beginSignInUXFlow()
                self.openPassTokens = OpenPassManager.main.openPassTokens
                self.error = nil
            } catch {
                self.openPassTokens = nil
                self.error = error
            }
        }
        
    }
    
    // MARK: - Sign In Data Access
    
    public func restorePreviousSignIn() {
        self.openPassTokens = OpenPassManager.main.restorePreviousSignIn()
    }
    
    public func signOut() {
        if OpenPassManager.main.signOut() {
            self.openPassTokens = nil
        }
    }
    
}
