//
//  AuthenticationTokensOIDCRow.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct AuthenticationTokensOIDCRow: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(LocalizedStringKey("root.label.oidcToken.idToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.oidcToken.idToken ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.oidcToken.accessToken"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.oidcToken.accessToken ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.oidcToken.tokenType"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.oidcToken.tokenType ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
    }
}
