//
//  NetworkSession.swift
//  
//
//  Created by Brad Leege on 11/8/22.
//

import Foundation

protocol NetworkSession {
    
    func loadData(for request: URLRequest) async throws -> Data
    
}
