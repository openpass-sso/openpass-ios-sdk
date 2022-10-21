//
//  RootViewModel.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Foundation
import OpenPass

class RootViewModel: ObservableObject {
    
    @Published var titleText = "OpenPass SDK"

    public func startLoginFlow() {
        OpenPassManager.main.beginSignInUXFlow { result in
            print("result = \(result)")
        }
    }
}
