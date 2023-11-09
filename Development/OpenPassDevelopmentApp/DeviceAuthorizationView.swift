//
//  DeviceAuthorizationView.swift
//  
//
//  Created by Brad Leege on 11/9/23.
//

import SwiftUI

#if os(tvOS)
struct DeviceAuthorizationView: View {
    
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
#endif
