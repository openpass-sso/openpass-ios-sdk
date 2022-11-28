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
                List {
                    Text(LocalizedStringKey("root.label.error"))
                        .font(Font.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                    Text(String(viewModel.error?.localizedDescription ?? "Error"))
                        .font(Font.system(size: 16, weight: .regular))
                }.listStyle(.plain)
            } else {
                List {
                    Section(header: Text(LocalizedStringKey("root.title.uid2Token"))
                                        .font(Font.system(size: 22, weight: .bold))) {
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.advertisingToken"))
                                .font(Font.system(size: 18, weight: .bold))
                            Text(String(viewModel.authenticateState?.uid2Token.advertisingToken ?? NSLocalizedString("common.nil", comment: "")))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.identityExpires"))
                                .font(Font.system(size: 18, weight: .bold))
                            Text(String(String(describing: viewModel.authenticateState?.uid2Token.identityExpires)))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.refreshToken"))
                                .font(Font.system(size: 20, weight: .bold))
                            Text(String(viewModel.authenticateState?.uid2Token.refreshToken ?? NSLocalizedString("common.nil", comment: "")))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.refreshFrom"))
                                .font(Font.system(size: 18, weight: .bold))
                            Text(String(describing: viewModel.authenticateState?.uid2Token.refreshFrom))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.refreshExpires"))
                                .font(Font.system(size: 18, weight: .bold))
                            Text(String(describing: viewModel.authenticateState?.uid2Token.refreshExpires))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                        Group {
                            Text(LocalizedStringKey("root.label.uid2Token.refreshResponseKey"))
                                .font(Font.system(size: 18, weight: .bold))
                            Text(String(viewModel.authenticateState?.uid2Token.refreshResponseKey ?? NSLocalizedString("common.nil", comment: "")))
                                .font(Font.system(size: 16, weight: .regular))
                        }
                    }
                }.listStyle(.plain)
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
