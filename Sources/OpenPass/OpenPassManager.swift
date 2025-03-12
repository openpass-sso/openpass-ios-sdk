//
//  OpenPassManager.swift
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

import AuthenticationServices
import Foundation
import OSLog
import Security

/// Legacy interface. Exists for backwards compatibility
/// 
@available(iOS 13.0, tvOS 16.0, *)
@MainActor
public final class OpenPassManager {

    private let configuration: Configuration
    private let tokenStore: TokenStore
    /// Singleton access point for OpenPassManager.
    @available(
    *,
     deprecated,
     renamed: "init(clientId:)",
     message: "Please create an explicit OpenPassManager instance using OpenPassManager.init()"
    )
    public static let shared = OpenPassManager.init()

    /// User data for the OpenPass user currently signed in.
    public private(set) var openPassTokens: OpenPassTokens?

    public func openPassTokensValues() -> AsyncStream<OpenPassTokens?> {
        tokenStore.openPassTokensValues()
    }

    /// Client specific redirect host
    private let redirectHost: String

    /// The SDK version
    public var sdkVersion: String {
        configuration.sdkVersion
    }

    private let tokenValidator: any IDTokenValidation

    private let log: OSLog

    /// This initializer is internal for testing.
    /// - Parameters:
    ///   - configuration: API and request parameters
    ///   - tokenValidator: ID Token validator
    ///   - clock: Clock implementation
    internal init(
        configuration legacyConfiguration: OpenPassConfiguration = OpenPassConfiguration(),
        tokenValidator: (any IDTokenValidation)? = nil,
        clock: Clock = RealClock()
    ) {
        // These are also validated in `beginSignInUXFlow`
        assert(!legacyConfiguration.clientId.isEmpty, "Missing `OpenPassClientId` in Info.plist")

        // Convert legacy configuration to new
        configuration = Configuration(legacyConfiguration)
        self.tokenValidator = tokenValidator ?? IDTokenValidator(
            clientID: configuration.clientId,
            issuerID: configuration.environment.endpoint.absoluteString.trimmingTrailing("/")
        )
        tokenStore = .keyChain(clientId: configuration.clientId)

        self.redirectHost = legacyConfiguration.redirectHost
        self.log = configuration.isLoggingEnabled
            ? OSLog(subsystem: "com.myopenpass", category: "OpenPassManager")
            : .disabled

        Task {
            openPassTokens = await tokenStore.load()
            for await tokens in tokenStore.openPassTokensValues() {
                openPassTokens = tokens
            }
        }
    }

    /// Signs user out by clearing all sign-in data currently in SDK.  This includes keychain and in-memory data.
    /// - Returns: True if signed out, False if still signed in.
    public func signOut() -> Bool {
        os_log("Signing Out", log: log, type: .debug)
        os_log("Clearing Tokens", log: log, type: .debug)
        Task {
            await self.tokenStore.store(tokens: nil)
        }
        return true
    }

    /// Starts the OpenID Connect (OAuth) Authentication User Interface Flow.
    /// - Returns: Authenticated ``OpenPassTokens``
    @discardableResult
    @available(
        *,
         deprecated,
         renamed: "signInFlow.beginSignIn",
         message: "Please create an explicit flow instance using the `signInFlow` and call its `beginSignIn()` method."
    )
    public func beginSignInUXFlow(redirectHost: String) async throws -> OpenPassTokens {
        return try await signInFlow.beginSignIn()
    }

    /// Returns an OpenID Connect (OAuth) Authentication User Interface Flow.
    /// The client will automatically updated the OpenPassManager's `openPassTokens` if the flow completes successfully.
    ///
    ///     let flow = OpenPassManager.shared.signInFlow
    ///     await try flow.beginSignIn()
    ///
    public var signInFlow: SignInFlow {
        return SignInFlow(
            configuration: configuration,
            redirectHost: self.redirectHost,
            storage: tokenStore
        )
    }

    /// Returns a client flow for refreshing tokens.
    /// The client will automatically updated the OpenPassManager's `openPassTokens` if it is successful in refreshing tokens.
    ///
    ///     if let refreshToken = OpenPassManager.shared.openPassTokens?.refreshToken {
    ///       let flow = OpenPassManager.shared.refreshTokenFlow
    ///       await try flow.refreshTokens(refreshToken)
    ///     }
    ///
    public var refreshTokenFlow: RefreshTokenFlow {
        RefreshTokenFlow(
            openPassClient: OpenPassClient(configuration: configuration),
            clientId: configuration.clientId,
            tokenValidator: tokenValidator,
            isLoggingEnabled: configuration.isLoggingEnabled
        ) { tokens in
            self.setOpenPassTokens(tokens)
        }
    }

    /// Returns a client flow for authorization with an external device.
    /// The client will automatically updated the OpenPassManager's `openPassTokens` if it is successful in refreshing tokens.
    public var deviceAuthorizationFlow: DeviceAuthorizationFlow {
        DeviceAuthorizationFlow(
            openPassClient: OpenPassClient(configuration: configuration),
            tokenValidator: tokenValidator,
            isLoggingEnabled: configuration.isLoggingEnabled
        ) { tokens in
            self.setOpenPassTokens(tokens)
        }
    }

    /// Utility function for persisting OpenPassTokens data after its been loaded from the API Server.
    internal func setOpenPassTokens(_ openPassTokens: OpenPassTokens) {
        os_log("Updating Tokens", log: log, type: .debug)
        assert(openPassTokens.idToken != nil, "ID Token must not be nil")
        self.openPassTokens = openPassTokens
        os_log("Saving Tokens", log: log, type: .debug)
        Task {
            await tokenStore.store(tokens: openPassTokens)
        }
    }
}
