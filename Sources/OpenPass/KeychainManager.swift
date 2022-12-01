//
//  KeychainManager.swift
//  
//
//  Created by Brad Leege on 12/1/22.
//

import Foundation
import Security

internal final class KeychainManager {
    
    /// Singleton access point for KeychainManager
    public static let main = KeychainManager()

    private let attrAccount = "openpass"
    
    private let attrService = "auth-state"
    
    private init() { }
    
    public func getAuthenticationStateFromKeychain() -> Data? {
        let query = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrAccount): attrAccount,
            String(kSecAttrService): attrService,
            String(kSecReturnData): true
        ] as CFDictionary
            
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
            
        return (result as? Data)
    }
    
    @discardableResult
    public func saveAuthenticationStateToKeychain(_ authenticationState: AuthenticationState) -> Bool {
        
        do {
            let data = try authenticationState.toData()

            if let _ = getAuthenticationStateFromKeychain() {
                
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
            print("Error trying to save data: \(error)")
        }

        return false
    }
    
    @discardableResult
    public func deleteAuthenticationStateFromKeychain() -> Bool {
        
        let query = [String(kSecClass): kSecClassGenericPassword]

        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
}
