//
//  BaseRequestParameterTests.swift
//
// MIT License
//
// Copyright (c) 2024 The Trade Desk (https://www.thetradedesk.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

@testable import OpenPass
import XCTest

final class FakeDevice: UIDevice {
    override var systemName: String {
        "XCTest OS"
    }

    override var systemVersion: String {
        "1.2.3"
    }

    override var model: String {
        "Test-o-matic 9000"
    }
}

@available(iOS 13.0, *)
final class BaseRequestParameterTests: XCTestCase {

    @MainActor
    func testHeader() async throws {
        let device = FakeDevice()
        let parameters = BaseRequestParameters(sdkName: "openpass-sdk-test", sdkVersion: "9000", device: device)
        XCTAssertEqual(
            parameters.asHeaderPairs,
            [
                "Device-Manufacturer": "Apple",
                "Device-Model": "Test-o-matic 9000",
                "Device-Platform": "XCTest OS",
                "Device-Platform-Version": "1.2.3",
                "SDK-Name": "openpass-sdk-test",
                "SDK-Version": "9000",
            ]
        )
    }

    func testPlatformHeader() throws {
        let parameters = BaseRequestParameters(sdkName: "openpass-sdk-test", sdkVersion: "9000")
#if os(iOS)
        XCTAssertEqual(
            parameters.asHeaderPairs,
            [
                "Device-Manufacturer": "Apple",
                "Device-Model": "iPhone",
                "Device-Platform": "iOS",
                "Device-Platform-Version": UIDevice.current.systemVersion,
                "SDK-Name": "openpass-sdk-test",
                "SDK-Version": "9000",
            ]
        )
#endif
#if os(tvOS)
        XCTAssertEqual(
            parameters.asHeaderPairs,
            [
                "Device-Manufacturer": "Apple",
                "Device-Model": "Apple TV",
                "Device-Platform": "tvOS",
                "Device-Platform-Version": UIDevice.current.systemVersion,
                "SDK-Name": "openpass-sdk-test",
                "SDK-Version": "9000",
            ]
        )
#endif
    }
}
