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

import Combine
import Foundation
import OpenPass
import SwiftUI

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = LocalizedStringKey("common.openpasssdk")
    @Published private(set) var openPassTokens: OpenPassTokens? = OpenPassManager.shared.openPassTokens
    @Published private(set) var error: Error?
    @Published var showDAF: Bool = false
    
    private var deviceClient: DeviceAuthorizationFlowClient?
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
    public func startSignInDAFFlow() {
        showDAF = true

        deviceClient = DeviceAuthorizationFlowClient(clientId: OpenPassManager.shared.clientId ?? "", setTokensOnManager: true)
        
        // Request that a new Device Code is requested.
        deviceClient?.fetchDeviceCode()

        deviceClient?.$state.sink(receiveValue: { state in
            print("state = \(state)")
        })
        .store(in: &cancellables)
        
        
/*
        deviceClient = DeviceAuthorizationFlowClient(clientId, manager)
        deviceClient?.let { client ->
            // Request that a new Device Code is requested.
            client.fetchDeviceCode()

            // Observe the results of the flow.
            client.state.collect { state ->
                Log.d(TAG, "Flow: $state")

                when (state) {
                    is Initialized -> Unit
                    is DeviceCodeAvailable -> _viewState.emit(AuthCodeAvailableState(state.deviceCode))
                    is DeviceCodeExpired -> _viewState.emit(AuthCodeExpiredState)
                    is DeviceAuthorizationFlowState.Error -> _viewState.emit(ErrorState(state.error))
                    is Complete -> {
                        val tokens = manager.currentTokens
                        if (tokens != null) {
                            Log.d(TAG, "Flow: Tokens Available")
                            _viewState.emit(SignedInState(tokens))
                        } else {
                            Log.d(TAG, "Flow: Tokens Not Available")
                            _viewState.emit(SignedOutState)
                        }
                    }
                }
            }
        }
        
*/

    }
    
    // MARK: - Sign Out Data Access
        
    public func signOut() {
        if OpenPassManager.shared.signOut() {
            self.openPassTokens = nil
        }
    }
    
}
