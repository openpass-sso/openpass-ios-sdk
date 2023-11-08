//
//  DeviceAuthorizationFlowClient.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Combine
import Foundation

@available(iOS 13.0, tvOS 16.0, *)
public final class DeviceAuthorizationFlowClient {
    
     /// The current state of the DeviceAuthorizationFlowClient.
    @Published public var state: DeviceAuthorizationFlowState = .complete
    
    // The currently fetched device code details. This includes the defined interval that we are required to poll the
    // token endpoint for to determine if/when the user completes their authorization flow.
    private var authorizeDeviceCodeResponse: AuthorizeDeviceCodeResponse?
    
    // When polling the token endpoint, it's possible that the response could ask us to "slow down". This means we need
    // to add an additional 5 seconds to the original interval we were configured with.
    private var slowDownFactor: Int64 = 0
    
    // An active Task that is scheduled to check whether the user has completed authorization.
    private var checkJob: Task<Void, Error>?
    
    // The interval is configurable via the response from the API. However, it's optional and if not includes, we
    // should default to 5 seconds.
    private let defaultIntervalSeconds: Int64 = 5

    // The number of additional seconds that should be added to the interval if asked to slow down (the polling).
    private let defaultSlowDownFactor: Int64 = 5
    
    /// Gets the current `DeviceCode`, if available.
    public var currentDeviceCode: DeviceCode? {
        switch state {
        case .deviceCodeAvailable(let deviceCode):
            return deviceCode
        default:
            return nil
        }
    }
    
    /// Gets whether or not the current [DeviceCode] has expired. If this is the case, a new instance needs to be
    /// re-fetched via [fetchDeviceCode].
    public var isExpired: Bool {
        switch state {
        case .deviceCodeExpired:
            return true
        default:
            return false
        }
    }
    
    /// Gets whether the current flow is complete.
    public var isComplete: Bool {
        switch state {
        case .complete:
            return true
        default:
            return false
        }
    }

    // MARK: - Init
    
    private let clientId: String
    private let setTokensOnManager: Bool
    
    public init(clientId: String, setTokensOnManager: Bool) {
        self.clientId = clientId
        self.setTokensOnManager = setTokensOnManager
    }
    
    // MARK: - Public API
    
    /// This starts the authorization flow by requesting a Device Code from the associated API server. The request is
    /// performed asynchronously with the results reported via the associated listener and/or state flow.
    ///
    /// Once called, it is important to call [cancel] if the results of the authorization
    /// flow are no longer required.
    public func fetchDeviceCode() {

        Task(priority: .userInitiated) {
           
            do {
                
                authorizeDeviceCodeResponse = try await OpenPassManager.shared.openPassClient?.getDeviceCode(clientId: clientId)
                
                guard let authorizeDeviceCodeResponse = authorizeDeviceCodeResponse else {
                    throw OpenPassError.unableToGenerateDeviceCode
                }

                let now = Date()
                let epochMs = Int64(now.timeIntervalSince1970 * 1000)
                setDeviceCodeInternal(authorizeDeviceCodeResponse.toDeviceCode(epochTimeMs: epochMs))
                
                // After we have received our device code response, we can start polling the token endpoint at the
                // given interval. This will allow us to detect when the user has completed their authorization flow.
                scheduleNextCheck()
            } catch let error {
                onError(error)
            }
        }

    }

     /// Cancels the current authorization flow.
     public func cancel() {

        // If we're being asked to cancel our current authorization flow, we should reset our state back to what it
        // was initially.
         authorizeDeviceCodeResponse = nil
        slowDownFactor = 0

        // Only update our device code if we haven't already completed the flow.
        if !isComplete {
            setDeviceCodeInternal(nil)
        }
    }

    /// Checks whether the user has successfully completed their (off device) authorization flow. If so, and we obtain
    /// our new set of tokens, these are provided to the [OpenPassManager]. If not, we
    private func checkAuthorization(_ deviceCode: String) async {
        do {
            // Check to see if the user has finished their authorization flow. If we are returned a set of tokens, this
            // indicates that we're complete. If not, we're required to schedule another request in the future, at an
            // interval defined by the API.
            let tokens = try await OpenPassManager.shared.openPassClient?.getTokenFromDeviceCode(clientId: clientId, deviceCode: deviceCode)
            
            guard let tokens = tokens else {
                throw OpenPassError.unableToGenerateTokenFromDeviceCode
            }
            
            // Verification needs to be done if both cases (setTokensOnManager true or false)
            guard let verified = try await OpenPassManager.shared.openPassClient?.verifyIDToken(tokens) else {
                throw OpenPassError.verificationFailedForOIDCToken
            }
            
            if !verified {
                throw OpenPassError.verificationFailedForOIDCToken
            }
            
            if setTokensOnManager {
                // Provide the tokens to the Manager, which internally will verify that they can be trusted before
                // storing the tokens.
                await OpenPassManager.shared.setOpenPassTokens(tokens)
            }
            
            // Since we've successfully obtains the new tokens, our flow is complete. The consumer will access this
            // new set of tokens directly with the OpenPassManager.
            state = .complete
        } catch let error {
            
            if let openPassError = error as? OpenPassError {
                if case .tokenAuthorizationPending = openPassError {
                    scheduleNextCheck()
                } else if case .tokenSlowDown = openPassError {
                    slowDownFactor += 1
                    scheduleNextCheck()
                } else if case .tokenExpired = openPassError {
                    setDeviceCodeInternal(nil, expired: true)
                } else {
                    onError(openPassError)
                }
                return
            }
            // Fall through
            onError(error)
        }

    }
    
    /// Reports when a new `DeviceCode` is available for the consuming application to request the user authorizes it.
    ///
    ///  Internally, changing the `DeviceCode` will abort any currently scheduled work to check a previous instance. If
    ///  the SDK should start checking again for the new instance, it's the caller's responsibility to call
    ///  `scheduleNextCheck`.
    ///
    private func setDeviceCodeInternal(_ deviceCode: DeviceCode?, expired: Bool = false) {
            // Cancel any previous Job to check if the previous DeviceCode has been successfully authorized.
            checkJob?.cancel()
            checkJob = nil

            guard let deviceCode = deviceCode else {
                if expired {
                    state = .deviceCodeExpired
                } else {
                    state = .complete
                }
                return
            }
            state = .deviceCodeAvailable(deviceCode)
        
        }
    
    /// Reports a given error via Flow interface.
    private func onError(_ error: Error) {
        state = .error(error)
    }

    /// Launches a new job to check if the user has authorized the device after the given interval (in seconds).
    private func scheduleNextCheck() {
        // Cancel any previous Job to check if the previous DeviceCode has been successfully authorized.
        checkJob?.cancel()
        checkJob = nil

        guard let authorizeDeviceCodeResponse = authorizeDeviceCodeResponse else {
            return
        }
            
        self.checkJob = Task {
            let baseInterval = authorizeDeviceCodeResponse.interval ?? defaultIntervalSeconds
            let interval = baseInterval + (slowDownFactor * defaultSlowDownFactor)
            let intervalInNanonSeconds = UInt64(interval * 1_000_000_000)
                
            guard let deviceCode = authorizeDeviceCodeResponse.deviceCode else {
                return
            }
            
            // delay
            try await Task.sleep(nanoseconds: intervalInNanonSeconds)
            await checkAuthorization(deviceCode)
        }
        
    }
    
}

extension DeviceAuthorizationFlowClient {
    
    /// A interface defining the flow of state communicated by the `DeviceAuthorizationFlowClient`
    public enum DeviceAuthorizationFlowState {

        /// A new ``DeviceCode`` is available.
        case deviceCodeAvailable(DeviceCode)

        /// The previous ``DeviceCode`` has now expired, and the consumer is required to re-start the flow via
        /// ``DeviceAuthorizationFlowClient.fetchDeviceCode()``.
        case deviceCodeExpired

        /// An unexpected error has occurred.
        case error(Error)

        /// The flow is complete and the associated `OpenPassManager` has obtained the set of `OpenPassTokens`.
        case complete
    }
    
}
