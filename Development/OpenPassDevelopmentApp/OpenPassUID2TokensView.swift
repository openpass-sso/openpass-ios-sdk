//
//  OpenPassUID2TokensView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 1/6/23.
//

import SwiftUI

struct OpenPassUID2TokensView: View {
    
    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
