//
//  OpenPassManagerTests.swift
//  
//
//  Created by Brad Leege on 10/13/22.
//

@testable import OpenPass
import XCTest

@available(iOS 13.0, *)
final class OpenPassManagerTests: XCTestCase {

    func testHelloWorld() throws {
        XCTAssertEqual(OpenPassManager.main.text, "Hello, World! This is the OpenPass SDK!")
    }

}