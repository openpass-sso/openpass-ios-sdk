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
    
    public func loadAuthenticationTokens() {
        self.authenticationTokens = OpenPassManager.main.loadAuthenticationTokens()
    }
    
    public func clearAuthenticationTokens() {
        if OpenPassManager.main.clearAuthenticationTokens() {
            self.authenticationTokens = nil
        }
    }
}
