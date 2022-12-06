//
//  AuthenticationTokensListView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 12/6/22.
//

import SwiftUI

struct AuthenticationTokensListView: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("root.title.authorization"))
                .font(Font.system(size: 22, weight: .bold))) {
                    AuthenticationTokensAcessRow(viewModel)
                }
            Section(header: Text(LocalizedStringKey("root.title.oidcToken"))
                .font(Font.system(size: 22, weight: .bold))) {
                    AuthenticationTokensOIDCRow(viewModel)
                }
            Section(header: Text(LocalizedStringKey("root.title.uid2Token"))
                                .font(Font.system(size: 22, weight: .bold))) {
                    AuthenticationTokensUID2Row(viewModel)
            }
        }.listStyle(.plain)

    }
}
