//
//  OpenPassTokensView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct OpenPassTokensView: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(LocalizedStringKey("root.label.openpassTokens.idToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(viewModel.idJWTToken)
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.accessToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(viewModel.accessToken)
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.tokenType"))
            .font(Font.system(size: 18, weight: .bold))
        Text(viewModel.tokenType)
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.expiresIn"))
            .font(Font.system(size: 18, weight: .bold))
        Text(viewModel.expiresIn)
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.email"))
            .font(Font.system(size: 18, weight: .bold))
        Text(viewModel.email)
            .font(Font.system(size: 16, weight: .regular))
    }
}
