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
    
    private var authURL: String?
    
    /// OpenPass Client Identifier
    private var clientId: String?
    
    /// OpenPass Client Redirect Uri
    private var redirectUri: String?
    
    private override init() {
        
        if let authURL = Bundle.main.object(forInfoDictionaryKey: "OpenPassAuthenticationURL") as? String,
            let clientId = Bundle.main.object(forInfoDictionaryKey: "OpenPassClientId") as? String,
            let redirectUri = Bundle.main.object(forInfoDictionaryKey: "OpenPassRedirectURI") as? String {
                self.authURL = authURL
                self.clientId = clientId
                self.redirectUri = redirectUri
        }

    }
    
    public func beginSignInUXFlow() {
        
        guard let url = URL(string: "https://www.thetradedesk.com") else {
            return
        }
        let callbackURL = "openpass"
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL) { callBackURL, error in
            print("callBackURL = \(String(describing: callBackURL)); error = \(String(describing: error))")
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
