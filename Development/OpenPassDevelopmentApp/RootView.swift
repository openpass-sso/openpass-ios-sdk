//
//  RootView.swift
//  OpenPassDevelopmentApp
//
//  Created by Brad Leege on 10/18/22.
//

import SwiftUI

struct RootView: View {
    
    private let viewModel = RootViewModel()
    
    var body: some View {
        Text(viewModel.titleText)
            .font(Font.system(size: 28, weight: .bold))
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .multilineTextAlignment(.center)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
