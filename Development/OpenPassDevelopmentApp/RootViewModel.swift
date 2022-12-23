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
    @Published private(set) var authenticationTokens: AuthenticationTokens?
    @Published private(set) var error: Error?
        
    // MARK: - Display Data Formatters
    
    var idJWTToken: String {
        if let token = authenticationTokens?.openPassTokens.idTokenJWT {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var accessToken: String {
        if let token = authenticationTokens?.openPassTokens.accessToken {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var tokenType: String {
        if let token = authenticationTokens?.openPassTokens.tokenType {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var expiresIn: String {
        if let token = authenticationTokens?.openPassTokens.expiresIn {
            return String(token)
        }
        return NSLocalizedString("common.nil", comment: "")
    }

    var email: String {
        if let email = authenticationTokens?.openPassTokens.idToken?.email {
            return email
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    // MARK: - UX Flows
    
    public func startLoginFlow() {

        Task(priority: .userInitiated) {
            do {
                try await OpenPassManager.main.beginSignInUXFlow()
                self.authenticationTokens = OpenPassManager.main.authenticationTokens
                self.error = nil
            } catch {
                self.authenticationTokens = nil
                self.error = error
            }
        }
    }
    
    // MARK: - Authentication Data Access
    
    public func loadAuthenticationTokens() {
        self.authenticationTokens = OpenPassManager.main.loadAuthenticationTokens()
    }
    
    public func clearAuthenticationTokens() {
        if OpenPassManager.main.clearAuthenticationTokens() {
            self.authenticationTokens = nil
        }
    }
    
}
