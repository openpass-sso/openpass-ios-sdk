//
//  File.swift
//  
//
//  Created by Brad Leege on 10/21/22.
//

import AuthenticationServices
import Foundation

extension OpenPassManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
