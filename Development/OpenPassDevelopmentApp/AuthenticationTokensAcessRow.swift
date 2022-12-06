//
//  AuthenticationTokensAcessRow.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct AuthenticationTokensAcessRow: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text(LocalizedStringKey("root.label.authorization.code"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.authorizeCode ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
        Text(LocalizedStringKey("root.label.authorization.state"))
            .font(Font.system(size: 18, weight: .bold))
        Text(String(viewModel.authenticationTokens?.authorizeState ?? NSLocalizedString("common.nil", comment: "")))
            .font(Font.system(size: 16, weight: .regular))
    }
}
