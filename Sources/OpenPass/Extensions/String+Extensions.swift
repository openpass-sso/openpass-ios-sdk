//
//  String+Extensions.swift
//  
//
//  Created by Brad Leege on 11/18/22.
//

import Foundation

extension String {
    
    /// Converts a base64 encoded string to a base64-url-encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> String {
            return replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
    }

    /// Decodes base64url-encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func decodeBase64URLSafe() -> Data? {
        let lengthMultiple = 4
        let paddingLength = lengthMultiple - count % lengthMultiple
        let padding = (paddingLength < lengthMultiple) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        return Data(base64Encoded: base64EncodedString)
    }
    
    
    /// Decode a JWT Component (header, payload, or signature)
    public func decodeJWTComponent() -> [String: Any]? {

        guard let componentData = decodeBase64URLSafe() else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: componentData, options: []) as? [String: Any]
        
    }
    
}
