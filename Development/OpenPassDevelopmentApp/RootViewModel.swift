//
//  RootViewModel.swift
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
import CoreImage.CIFilterBuiltins
import Foundation
import OpenPass
import SwiftUI

@MainActor
class RootViewModel: ObservableObject {
    
    @Published private(set) var titleText = LocalizedStringKey("common.openpasssdk")
    @Published private(set) var openPassTokens: OpenPassTokens? = OpenPassManager.shared.openPassTokens
    @Published private(set) var error: Error?
    @Published var showDAF: Bool = false {
        didSet {
            if showDAF == false {
                deviceCode = nil
            }
        }
    }
    @Published var deviceCode: DeviceCode?
    
    @Published var verificationUriCompleteImage: UIImage?

    private var deviceClient: DeviceAuthorizationFlowClient?
    
    private var cancellables = Set<AnyCancellable>()

    var canRefreshTokens: Bool {
        openPassTokens?.refreshToken != nil
    }

    // MARK: - Display Data Formatters
    
    var idJWTToken: String {
        if let token = openPassTokens?.idTokenJWT {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var accessToken: String {
        if let token = openPassTokens?.accessToken {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var tokenType: String {
        if let token = openPassTokens?.tokenType {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    var expiresIn: String {
        if let token = openPassTokens?.expiresIn {
            return String(token)
        }
        return NSLocalizedString("common.nil", comment: "")
    }

    var refreshToken: String {
        if let token = openPassTokens?.refreshToken {
            return token
        }
        return NSLocalizedString("common.nil", comment: "")
    }

    var email: String {
        if let email = openPassTokens?.idToken?.email {
            return email
        }
        return NSLocalizedString("common.nil", comment: "")
    }
    
    // MARK: - UX Flows
    
    public func startSignInUXFlow() {
                
        Task(priority: .userInitiated) {
            do {
                try await OpenPassManager.shared.beginSignInUXFlow()
                self.openPassTokens = OpenPassManager.shared.openPassTokens
                self.error = nil
            } catch {
                self.openPassTokens = nil
                self.error = error
            }
        }
        
    }

    #if os(tvOS)
    public func startSignInDAFFlow() {
        signOut()
        showDAF = true

        let deviceClient = OpenPassManager.shared.deviceAuthorizationFlow

        // Request that a new Device Code is requested.
        deviceClient.fetchDeviceCode()

        deviceClient.$state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
            print("state = \(state)")

            guard let self else { return }

            switch state {
            case .deviceCodeAvailable(let deviceCode):
                self.deviceCode = deviceCode
                if let verificationUriComplete = deviceCode.verificationUriComplete {
                    verificationUriCompleteImage = qrCodeImage(url: verificationUriComplete)!
                }
            case .deviceCodeExpired:
                self.deviceCode = nil
            case .error(let error):
                self.error = error
            case .complete:
                if let tokens = OpenPassManager.shared.openPassTokens {
                    self.openPassTokens = tokens
                    self.error = nil
                    self.showDAF = false
                }
            }
        })
        .store(in: &cancellables)

        self.deviceClient = deviceClient

    }

    private func qrCodeImage(url: String) -> UIImage? {
        guard let data = url.data(using: String.Encoding.ascii) else {
            return nil
        }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let output = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        // The generated image isn't suitable for rendering as-is. Convert to PNG and back.
        return UIImage(ciImage: output).pngData().flatMap(UIImage.init(data: ))
//        return UIImage(data: UIImage(ciImage: output).pngData()!)
    }
    #endif

    // MARK: - Sign In Data Access

    public func refreshTokenFlow() {
        let manager = OpenPassManager.shared
        guard let refreshToken = manager.openPassTokens?.refreshToken else {
            // Button should be disabled
            return
        }

        Task(priority: .userInitiated) {
            do {
                let flow = manager.refreshTokenFlow
                self.openPassTokens = try await flow.refreshTokens(refreshToken)
            }
        }
    }

    // MARK: - Sign Out Data Access

    public func signOut() {
        if OpenPassManager.shared.signOut() {
            self.openPassTokens = nil
        }
        self.error = nil
    }
    
}
