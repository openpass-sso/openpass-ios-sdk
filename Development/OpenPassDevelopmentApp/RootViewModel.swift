//
//  RootViewModel.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Foundation
import OpenPass
import SwiftUI

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = LocalizedStringKey("common.openpasssdk")
    @Published private(set) var openPassTokens: OpenPassTokens?
    @Published private(set) var openPassUID2Tokens: OpenPassUID2Tokens?
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
    
    // MARK: - OpenPass UID2 Data
    
    public func generateOpenPassUID2Tokens() async throws {
        let openPassUID2Tokens = try await OpenPassManager.main.generateOpenPassUID2Tokens()
        self.openPassUID2Tokens = openPassUID2Tokens
    }
}
