//
//  RootView.swift
//
// MIT License
//
// Copyright (c) 2022 The Trade Desk (https://www.thetradedesk.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
                ErrorListView(viewModel)
            } else {
                OpenPassTokensView(viewModel)
                Spacer()
            }
            HStack(alignment: .center, spacing: 20.0) {
                Button(LocalizedStringKey("root.button.signout")) {
                    viewModel.signOut()
                }.padding()
                Button(LocalizedStringKey("root.button.signin")) {
                    viewModel.startSignInUXFlow()
                }.padding()
                Button(LocalizedStringKey("root.button.daf")) {
                    viewModel.startSignInDAFFlow()
                }.padding()
            }
            .sheet(isPresented: $viewModel.showDAF, content: {
                DAFView(viewModel)
                    .presentationDetents([.medium])
            })
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

struct DAFView: View {
    
    @ObservedObject
    private var viewModel: RootViewModel

    init(_ viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16.0) {
            Text(LocalizedStringKey("daf.label.usercode"))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.deviceCode?.userCode ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(LocalizedStringKey("daf.label.verificationuri"))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.deviceCode?.verificationUri ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(LocalizedStringKey("daf.label.verficationuricomplete"))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.deviceCode?.verificationUriComplete ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 16.0)
    }
    
}
