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
    @Published private(set) var authenticateState: AuthenticationState?
    @Published private(set) var error: Error?
    
    public func startLoginFlow() {

        Task(priority: .userInitiated) {
            do {
                let authenticateState = try await OpenPassManager.main.beginSignInUXFlow()
                self.authenticateState = authenticateState
                self.error = nil
            } catch {
                self.authenticateState = nil
                self.error = error
            }
        }
    }
    
    public func loadAuthenticationState() {
        self.authenticateState = OpenPassManager.main.loadAuthenticationState()
    }
    
    public func clearAuthenticationState() {
        if OpenPassManager.main.clearAuthenticationState() {
            self.authenticateState = nil
        }
    }
}
