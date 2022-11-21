//
//  RootViewModel.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Foundation
import OpenPass

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = "OpenPass SDK"
    @Published private(set) var uid2AdvertisingToken = "Nil"
    @Published private(set) var uid2RefreshToken = "Nil"
    @Published private(set) var error: Error?
    
    public func startLoginFlow() {

        Task(priority: .userInitiated) {
            do {
                let uid2Token = try await OpenPassManager.main.beginSignInUXFlow()
                print("uid2Token = \(uid2Token)")
                self.uid2AdvertisingToken = uid2Token.advertisingToken ?? "Nil"
                self.uid2RefreshToken = uid2Token.refreshToken ?? "Nil"
                self.error = nil
            } catch {
                self.error = error
            }
        }
        
/*
        self?.code = dictionary["code"] ?? "Nil"
        self?.state = dictionary["state"] ?? "Nil"
        self?.error = nil

        
        
        OpenPassManager.main.beginSignInUXFlow { [weak self] result in
            switch result {
            case .success(let dictionary):
                self?.code = dictionary["code"] ?? "Nil"
                self?.state = dictionary["state"] ?? "Nil"
                self?.error = nil
            case .failure(let error):
                self?.error = error
            }
        }
*/
    }
}
