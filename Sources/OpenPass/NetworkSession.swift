//
//  NetworkSession.swift
//  
//
//  Created by Brad Leege on 11/8/22.
//

import Foundation

/// Common interface for networking and unit testing

@available(iOS 13.0, *)
protocol NetworkSession {
    
    func loadData(for request: URLRequest) async throws -> Data
    
}
