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
                HStack {
                    Text(LocalizedStringKey("root.label.error"))
                        .font(Font.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                    Text(String(viewModel.error?.localizedDescription ?? "Error"))
                        .font(Font.system(size: 16, weight: .regular))
                }.padding()
            } else {
                HStack {
                    Text(LocalizedStringKey("root.label.code"))
                        .font(Font.system(size: 20, weight: .bold))
                    Text(String(viewModel.code))
                        .font(Font.system(size: 16, weight: .regular))
                }.padding()
                HStack {
                    Text(LocalizedStringKey("root.label.state"))
                        .font(Font.system(size: 20, weight: .bold))
                    Text(String(viewModel.state))
                        .font(Font.system(size: 16, weight: .regular))
                }.padding()
            }
            Button("Login With OpenPass") {
                viewModel.startLoginFlow()
            }.padding()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
