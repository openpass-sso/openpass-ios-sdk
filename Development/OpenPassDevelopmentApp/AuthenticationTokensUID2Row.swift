//
//  AuthenticationTokensUID2Row.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct AuthenticationTokensUID2Row: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            Text(LocalizedStringKey("root.label.uid2Token.advertisingToken"))
                .font(Font.system(size: 18, weight: .bold))
            Text(String(viewModel.authenticationTokens?.uid2Token.advertisingToken ?? NSLocalizedString("common.nil", comment: "")))
                .font(Font.system(size: 16, weight: .regular))
            Text(LocalizedStringKey("root.label.uid2Token.identityExpires"))
                .font(Font.system(size: 18, weight: .bold))
            Text(String(String(describing: viewModel.authenticationTokens?.uid2Token.identityExpires)))
                .font(Font.system(size: 16, weight: .regular))
            Text(LocalizedStringKey("root.label.uid2Token.refreshToken"))
                .font(Font.system(size: 20, weight: .bold))
            Text(String(viewModel.authenticationTokens?.uid2Token.refreshToken ?? NSLocalizedString("common.nil", comment: "")))
                .font(Font.system(size: 16, weight: .regular))
        }
        Group {
            Text(LocalizedStringKey("root.label.uid2Token.refreshFrom"))
                .font(Font.system(size: 18, weight: .bold))
            Text(String(describing: viewModel.authenticationTokens?.uid2Token.refreshFrom))
                .font(Font.system(size: 16, weight: .regular))
            Text(LocalizedStringKey("root.label.uid2Token.refreshExpires"))
                .font(Font.system(size: 18, weight: .bold))
            Text(String(describing: viewModel.authenticationTokens?.uid2Token.refreshExpires))
                .font(Font.system(size: 16, weight: .regular))
            Text(LocalizedStringKey("root.label.uid2Token.refreshResponseKey"))
                .font(Font.system(size: 18, weight: .bold))
            Text(String(viewModel.authenticationTokens?.uid2Token.refreshResponseKey ?? NSLocalizedString("common.nil", comment: "")))
                .font(Font.system(size: 16, weight: .regular))
        }
    }
}
