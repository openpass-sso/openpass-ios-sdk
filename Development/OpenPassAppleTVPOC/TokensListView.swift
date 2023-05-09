//
//  TokensListView.swift
//  OpenPassAppleTVPOC
//
//  Created by Brad Leege on 5/8/23.
//

import SwiftUI

struct TokensListView: View {

    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section(header: Text(LocalizedStringKey("root.title.openpassTokens"))
                .font(Font.system(size: 22, weight: .bold))) {
                    OpenPassTokensView(viewModel)
                }
        }.listStyle(.plain)

    }
}
