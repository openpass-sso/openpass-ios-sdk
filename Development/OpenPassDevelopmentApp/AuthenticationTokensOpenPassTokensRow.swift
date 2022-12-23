//
//  AuthenticationTokensOpenPassTokensRow.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct AuthenticationTokensOpenPassTokensRow: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(LocalizedStringKey("root.label.openpassTokens.idToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.openPassTokens.idTokenJWT ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.accessToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.openPassTokens.accessToken ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.tokenType"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.openPassTokens.tokenType ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.openpassTokens.email"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.openPassTokens.idToken?.email ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
    }
}
