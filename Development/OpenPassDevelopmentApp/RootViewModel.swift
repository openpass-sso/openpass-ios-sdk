//
//  RootViewModel.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Foundation
import OpenPass

class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = "OpenPass SDK"
    @Published private(set) var code = "Nil"
    @Published private(set) var state = "Nil"

    public func startLoginFlow() {
        OpenPassManager.main.beginSignInUXFlow { [weak self] result in
            print("result = \(result)")
            switch result {
            case .success(let dictionary):
                self?.code = dictionary["code"] ?? "Nil"
                self?.state = dictionary["state"] ?? "Nil"
            case .failure(let error):
                print("Authentication Failed: \(error)")
            }
        }
    }
}
