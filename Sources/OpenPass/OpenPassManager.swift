//
//  OpenPassManager.swift
//  OpenPass
//
//  Created by Brad Leege on 10/11/22.
//

import AuthenticationServices
import Foundation

@available(iOS 13.0, *)
public struct OpenPassManager {
    
    public static let main = OpenPassManager()
    
    public private(set) var text = "Hello, World! This is the OpenPass SDK!"
    
    private init() { }
    
}
