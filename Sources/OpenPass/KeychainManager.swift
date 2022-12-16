//
//  KeychainManager.swift
//  
//
//  Created by Brad Leege on 12/1/22.
//

import Foundation
import Security

/// Securely manages data in the Keychain

@available(iOS 13.0, *)
internal final class KeychainManager {
    
    /// Singleton access point for KeychainManager
    public static let main = KeychainManager()

    private let attrAccount = "openpass"
    
    private let attrService = "auth-state"
    
    private init() { }
    
    public func getAuthenticationTokensFromKeychain() -> AuthenticationTokens? {
        let query = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): attrAccount,
            String(kSecAttrService): attrService,
            String(kSecReturnData): true
        ] as CFDictionary
            
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
            
        if let data = result as? Data {
            return AuthenticationTokens.fromData(data)
        }
        
        return nil
    }
    
    @discardableResult
    public func saveAuthenticationTokensToKeychain(_ authenticationTokens: AuthenticationTokens) -> Bool {
        
        do {
            let data = try authenticationTokens.toData()

            if let _ = getAuthenticationTokensFromKeychain() {
                
                let query = [
                    String(kSecClass): kSecClassGenericPassword,
                    String(kSecAttrService): attrService,
                    String(kSecAttrAccount): attrAccount
                ] as CFDictionary
                
                let attributesToUpdate = [String(kSecValueData): data] as CFDictionary
                
                let result = SecItemUpdate(query, attributesToUpdate)
                return result == errSecSuccess
            } else {
                let keychainItem: [String: Any] = [
                    String(kSecClass): kSecClassGenericPassword,
                    String(kSecAttrAccount): attrAccount,
                    String(kSecAttrService): attrService,
                    String(kSecUseDataProtectionKeychain): true,
                    String(kSecValueData): data
                ]

                let result = SecItemAdd(keychainItem as CFDictionary, nil)
                return result == errSecSuccess
            }
        } catch {
            // Fall through to return false
        }

        return false
    }
    
    @discardableResult
    public func deleteAuthenticationTokensFromKeychain() -> Bool {
        
        let query: [String: Any] = [String(kSecClass): kSecClassGenericPassword,
                                    String(kSecAttrAccount): attrAccount,
                                    String(kSecAttrService): attrService]

        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
}
