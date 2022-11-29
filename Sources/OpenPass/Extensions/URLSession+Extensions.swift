//
//  URLSession+Extensions.swift
//  
//
//  Created by Brad Leege on 11/8/22.
//

import Foundation

extension URLSession: NetworkSession {

    func loadData(for request: URLRequest) async throws -> Data {
        let (data, _) = try await data(for: request)
        return data
    }
    
}
