//
//  DeviceAuthorizationFlowClient.swift
//
//
//  Created by Brad Leege on 10/31/23.
//

import Combine
import Foundation

@available(tvOS 16.0, *)
final class DeviceAuthorizationFlowClient {
    
     /// The current state of the DeviceAuthorizationFlowClient.
    @Published var state: DeviceAuthorizationFlowState = .complete
    
    private let clientId: String
    
    init(clientId: String) {
        self.clientId = clientId
    }
    
    
}

extension DeviceAuthorizationFlowClient {
    
    /// A interface defining the flow of state communicated by the [DeviceAuthorizationFlowClient]
    enum DeviceAuthorizationFlowState {

        /// A new [DeviceCode] is available.
        case deviceCodeAvailable(DeviceCode)

        /// The previous [DeviceCode] has now expired, and the consumer is required to re-start the flow via
        /// [DeviceAuthorizationFlowClient.fetchDeviceCode].
        case deviceCodeExpired

        /// An unexpected error has occurred.
        case error(Error)

        /// The flow is complete and the associated [OpenPassManager] has obtained the set of [OpenPassTokens].
        case complete
    }
    
}
