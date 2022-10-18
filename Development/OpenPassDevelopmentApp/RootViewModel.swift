//
//  RootViewModel.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Foundation
import OpenPass

class RootViewModel: ObservableObject {
    
    @Published var titleText: String

    init(titleText: String? = nil) {
        if let titleText {
            self.titleText = titleText
        } else {
            self.titleText = OpenPassManager.main.text
        }
    }
    
}
