//
//  OpenPassManager.swift
//  OpenPass
//
//  Created by Brad Leege on 10/11/22.
//

import AuthenticationServices
import Foundation

@available(iOS 13.0, *)
public final class OpenPassManager: NSObject {
    
    public static let main = OpenPassManager()
    
    public private(set) var text = "Hello, World! This is the OpenPass SDK!"
    
    private override init() { }
    
    public func beginSignInUXFlow() {
        
        guard let url = URL(string: "https://www.thetradedesk.com") else {
            return
        }
        let callbackURL = "openpass"
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL) { callBackURL, error in
            print("callBackURL = \(callbackURL); error = \(String(describing: error))")
        }
        
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = self
        session.start()
    }
    
}

extension OpenPassManager: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
