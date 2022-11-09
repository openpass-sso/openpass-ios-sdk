//
//  MockNetworkSession.swift
//  
//
//  Created by Brad Leege on 11/8/22.
//

import Foundation
@testable import OpenPass

class MockNetworkSession: NetworkSession {

    private let fileName: String
    private let fileExtension: String
    
    init(_ fileName: String, _ fileExtension: String) {
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
    
    func loadData(for request: URLRequest) async throws -> Data {

//        throw "Commented out for building."
//        return Data()
                
        // Bundle.module.path(forResource: "token-200", ofType: "json", inDirectory: "TestData")
        
        guard let bundlePath = Bundle.module.path(forResource: fileName, ofType: fileExtension, inDirectory: "TestData"),
              let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
            throw "Could not load JSON from file."
        }

        return jsonData
    }
    
}
