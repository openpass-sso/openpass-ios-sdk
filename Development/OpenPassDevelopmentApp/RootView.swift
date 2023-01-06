//
//  RootView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import Combine
import SwiftUI

struct RootView: View {
    
    @ObservedObject
    private var viewModel = RootViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.titleText)
                .font(Font.system(size: 28, weight: .bold))
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            if viewModel.error != nil {
                ErrorListView(viewModel)
            } else {
                TokensListView(viewModel)
            }
            HStack(alignment: .center, spacing: 20.0) {
                Button(LocalizedStringKey("root.button.signout")) {
                    viewModel.signOut()
                }.padding()
                Button(LocalizedStringKey("root.button.signin")) {
                    viewModel.startSignInUXFlow()
                }.padding()
                 if let _ = viewModel.openPassTokens {
                     Button(LocalizedStringKey("root.button.uid2Tokens")) {
                         viewModel.generateOpenPassUID2Tokens()
                     }.padding()
                 }
            }
        }.onAppear {
            viewModel.restorePreviousSignIn()
        }
    }
}
