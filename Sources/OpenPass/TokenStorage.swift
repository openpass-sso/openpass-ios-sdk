//
//  OpenPassManager.swift
//
// MIT License
//
// Copyright (c) 2025 The Trade Desk (https://www.thetradedesk.com/)
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

protocol TokenStorage {
    func load() async -> OpenPassTokens?
    func store(tokens: OpenPassTokens?) async
}

final class InMemoryStorage: TokenStorage {
    private var tokens: OpenPassTokens?

    func load() -> OpenPassTokens? {
        tokens
    }
    func store(tokens: OpenPassTokens?) {
        self.tokens = tokens
    }
}

final class KeyChainStorage: TokenStorage {
    func load() -> OpenPassTokens? {
        KeychainManager.main.getOpenPassTokensFromKeychain()
    }

    func store(tokens: OpenPassTokens?) {
        if let tokens {
            KeychainManager.main.saveOpenPassTokensToKeychain(tokens)
        } else {
            KeychainManager.main.deleteOpenPassTokensFromKeychain()
        }
    }
}

@MainActor
public final class TokenStore {
    private let clientId: String
    private let storage: any TokenStorage

    public static func inMemory(clientId: String) -> TokenStore {
        TokenStore(clientId: clientId, storage: InMemoryStorage())
    }
    public static func keyChain(clientId: String) -> TokenStore {
        TokenStore(clientId: clientId, storage: KeyChainStorage())
    }

    /// User data for the OpenPass user currently signed in.
    public private(set) var openPassTokens: OpenPassTokens? {
        didSet {
            // Capture the current value in the queue operation
            queue.enqueue { [openPassTokens] in
                await self.storage.store(tokens: openPassTokens)
                await self.broadcaster.send(openPassTokens)
            }
        }
    }

    private let broadcaster = Broadcaster<OpenPassTokens?>()
    private let queue = Queue()
    public func openPassTokensValues() -> AsyncStream<OpenPassTokens?> {
        broadcaster.values()
    }

    init(
        clientId: String,
        storage: any TokenStorage
    ) {
        self.clientId = clientId
        self.storage = storage

        Task {
            // Restore cached token, if non-nil
            if let tokens = await load() {
                openPassTokens = tokens
            }
        }
    }

    public func load() async -> OpenPassTokens? {
        await storage.load()
    }

    public func store(tokens: OpenPassTokens?) async {
        openPassTokens = tokens
    }
}
