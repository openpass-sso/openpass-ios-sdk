//
//  OpenPassManagerTests.swift
//  
//
//  Created by Brad Leege on 10/13/22.
//

import XCTest
@testable import OpenPass

final class OpenPassManagerTests: XCTestCase {

    func testHelloWorld() throws {
        let manager = OpenPassManager()
        XCTAssertEqual(manager.text, "Hello, World! This is the OpenPass SDK!")
    }

}
