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
            Section(header: Text(LocalizedStringKey("root.title.oidcToken"))
                .font(Font.system(size: 22, weight: .bold))) {
                    AuthenticationTokensOpenPassTokensRow(viewModel)
                }
        }.listStyle(.plain)

    }
}
