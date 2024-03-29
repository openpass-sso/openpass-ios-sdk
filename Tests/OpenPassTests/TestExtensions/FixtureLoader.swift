//
//  FixtureLoader.swift
//
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
//The above copyright notice and this permission notice shall be included in all
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

import Foundation

internal final class FixtureLoader {
    enum Error: Swift.Error {
        case missingFixture(String)
    }

    /// Read `Data` from a Fixture.
    static func data(
        fixture: String,
        withExtension fileExtension: String = "json",
        subdirectory: String = "TestData"
    ) throws -> Data {
        guard let fixtureURL = Bundle.module.url(
            forResource: fixture,
            withExtension: fileExtension,
            subdirectory: subdirectory
        ) else {
            throw Error.missingFixture("\(subdirectory)/\(fixture).\(fileExtension)")
        }
        return try Data(contentsOf: fixtureURL)
    }

    /// Decode a `Decodable` from a Fixture.
    /// Expects the fixture to use snake_case key encoding.
    static func decode<T>(
        _ type: T.Type,
        fixture: String,
        withExtension fileExtension: String = "json",
        subdirectory: String = "TestData"
    ) throws -> T where T : Decodable {
        let data = try data(fixture: fixture, withExtension: fileExtension, subdirectory: subdirectory)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
}
