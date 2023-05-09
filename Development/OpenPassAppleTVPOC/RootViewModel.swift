//
//  RootViewModel.swift
//  OpenPassAppleTVPOC
//
//  Created by Brad Leege on 5/8/23.
//

import Foundation
import OpenPass
import SwiftUI

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = LocalizedStringKey("common.openpasssdk")
    @Published private(set) var openPassTokens: OpenPassTokens? = OpenPassManager.shared.openPassTokens
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
                try await OpenPassManager.shared.beginSignInUXFlow()
                self.openPassTokens = OpenPassManager.shared.openPassTokens
                self.error = nil
            } catch {
                self.openPassTokens = nil
                self.error = error
            }
        }
        
    }
    
    // MARK: - Sign In Data Access
        
    public func signOut() {
        if OpenPassManager.shared.signOut() {
            self.openPassTokens = nil
        }
    }
    
}
