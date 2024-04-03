//
//  HTTPStub.swift
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

internal final class HTTPStub {
    static let shared: HTTPStub = {
        let stub = HTTPStub()
        URLProtocol.registerClass(HTTPStubProtocol.self)
        return stub
    }()

    private init() {}

    // Provides stubs in response to requests
    var stubs: ((URLRequest) -> Result<(data: Data, response: HTTPURLResponse), Error>)!

    // Stub for the current request
    private var stub: Result<(data: Data, response: HTTPURLResponse), Error>!

    private class HTTPStubProtocol: URLProtocol {
        private var isCancelled = false

        override class func canInit(with: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            // Set the active stub
            HTTPStub.shared.stub = HTTPStub.shared.stubs(request)
            return request
        }

        override func startLoading() {
            let stub = HTTPStub.shared.stub!

            let queue = DispatchQueue.global(qos: .default)
            queue.asyncAfter(deadline: .now() + 0.01) {
                guard !self.isCancelled, let client = self.client else {
                    return
                }

                switch stub {
                case .success(let (data, response)):
                    client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    client.urlProtocol(self, didLoad: data)
                case .failure(let error):
                    client.urlProtocol(self, didFailWithError: error)
                }

                client.urlProtocolDidFinishLoading(self)
            }
        }

        override func stopLoading() {
            isCancelled = true
        }
    }
}

internal extension HTTPURLResponse {
    convenience init(
        url: URL,
        statusCode: Int = 200,
        httpVersion: String = "1.1",
        headerFields: [String:String]? = nil
    ) {
        self.init(
            url: url,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: nil
        )!
    }
}

struct MissingFixtureError: Error, LocalizedError {
    var url: URL

    var errorDescription: String? {
        "No stub registered for path \(url.path)"
    }
}

extension HTTPStub {

    /// Stub HTTP requests using a mapping of request URL path to Fixture name and statusCode.
    /// This supports most test cases which do not require more advanced url matching, or to return errors.
    func stub(fixtures: [String:(String, Int)]) throws {
        let fixtureDatas = try fixtures.mapValues { (fixture, statusCode) in
            let data = try FixtureLoader.data(fixture: fixture)
            return (data, statusCode)
        }
        stubs = { request in
            let url = request.url!
            let path = url.path
            guard let (data, statusCode) = fixtureDatas[path] else {
                return .failure(MissingFixtureError(url: url))
            }
            return .success((data, .init(url: url, statusCode: statusCode)))
        }
    }
}

extension HTTPStub {
    /// A convenience method to configure all HTTP requests to return successfully with data from the given `fixture`, and `statusCode`.
    func stubAlways(fixture: String, statusCode: Int = 200) throws {
        let data = try FixtureLoader.data(fixture: fixture)
        stubAlways(data: data, statusCode: statusCode)
    }

    /// A convenience method to configure all HTTP requests to return successfully with the given `data` and `statusCode`.
    func stubAlways(data: Data, statusCode: Int = 200) {
        stubs = { request in
            .success((data, .init(url: request.url!)))
        }
    }

    /// A convenience method to configure all HTTP requests to return failure with an `error`.
    func stubAlways(error: Error) {
        stubs = { _ in
            .failure(error)
        }
    }
}
