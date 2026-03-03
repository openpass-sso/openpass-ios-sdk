# CLAUDE.md

This file provides guidance to AI agents and automatations such as Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenPass iOS SDK is a Swift Package Manager library providing OpenID Connect (OAuth) authentication for iOS (13.0+) and tvOS (16.0+) apps. It is in production use — the public API must be stable. Avoid public API changes unless absolutely necessary. Do not add new dependencies.

Use Swift, not Objective-C. Use Swift 6.2 features and support Xcode 26 onwards.

## Commands

All `xcodebuild` commands should be run from the repository root. With the exception of UI Tests, run commands against the Swift Package (no `-project` argument).

**Run unit tests:**
```bash
xcodebuild -scheme OpenPass -destination "name=iPhone 17 Pro,OS=latest,platform=iOS Simulator" test
```

**Run a single test class or method** (add `-only-testing` flag):
```bash
xcodebuild -scheme OpenPass -destination "name=iPhone 17 Pro,OS=latest,platform=iOS Simulator" test -only-testing OpenPassTests/OpenPassManagerTests
```

**Run Mobile Sign-in UI Tests:**
```bash
xcodebuild test -project Development/OpenPassDevelopmentApp.xcodeproj -scheme OpenPassDevelopmentApp -testPlan OpenPassDevelopmentAppUITests-Mobile -destination 'OS=26.2,name=iPhone 17 Pro'
```

**Run Device Authorization UI Tests:**
```bash
xcodebuild test -project Development/OpenPassDevelopmentApp.xcodeproj -scheme OpenPassDevelopmentApp -testPlan OpenPassDevelopmentAppUITests-DeviceAuth -destination 'OS=26.2,name=iPhone 17 Pro'
```

## Architecture

### Package Structure

- **`Sources/OpenPass/`** — The main SDK library (no external dependencies)
- **`Sources/OpenPassObjC/`** — Objective-C bridge wrapping the Swift library
- **`Tests/OpenPassTests/`** — Unit tests for the SDK
- **`Tests/OpenPassObjCTests/`** — ObjC bridge tests. Objective-C is permitted here.
- **`Tests/ObjCTestHelpers/`** — Swift helpers used from ObjC tests
- **`Development/OpenPassDevelopmentApp/`** — iOS development/manual testing app (`.xcodeproj`)
- **`Development/OpenPassDevelopmentAppUITests/`** — UI test suite with two test plans

### Core Components

**`OpenPassManager`** (`Sources/OpenPass/OpenPassManager.swift`) — The singleton entry point (`OpenPassManager.shared`). Manages the current user session (`openPassTokens`), persists tokens to Keychain, and vends flow objects. Annotated `@MainActor`.

**Flow objects** — Obtained from `OpenPassManager`; each represents one authentication flow:
- `SignInFlow` — OAuth PKCE web-based sign-in using `ASWebAuthenticationSession`
- `RefreshTokenFlow` — Refreshes an existing token
- `DeviceAuthorizationFlow` — Two-step device code flow (for tvOS/input-constrained devices); polls for authorization

**`OpenPassClient`** (`Sources/OpenPass/OpenPassClient.swift`) — Internal HTTP networking layer. Builds `URLRequest`s from `Request<ResponseType>` value types, executes via `URLSession.shared`, and decodes JSON responses using snake_case conversion.

**`OpenPassConfiguration`** (`Sources/OpenPass/OpenPassConfiguration.swift`) — Reads config from `Info.plist` keys (`OpenPassClientId`, `OpenPassRedirectHost`, `OpenPassBaseURL`) with fallback to `OpenPassSettings`. Contains `openPassSdkVersion` — update this for releases.

**`OpenPassSettings`** (`Sources/OpenPass/OpenPassSettings.swift`) — `@objc` singleton for programmatic configuration as an alternative to Info.plist. Must be set before `OpenPassManager.shared` is first accessed.

**`IDTokenValidator`** (`Sources/OpenPass/IDTokenValidation.swift`) — Validates JWT ID tokens: issuer, audience, expiry, and RSA signature against JWKS.

**`KeychainManager`** — Persists/retrieves `OpenPassTokens` from the iOS Keychain.

### Data Flow

1. App calls a flow via `OpenPassManager.shared.signInFlow.beginSignIn()` (or `refreshTokenFlow`/`deviceAuthorizationFlow`)
2. Flow communicates with `OpenPassClient` for API calls, performs PKCE (for sign-in), and validates the returned ID token against JWKS
3. On success, flow calls its `tokensObserver` closure which updates `OpenPassManager.openPassTokens` and persists to Keychain
4. Tokens are broadcast via `AsyncStream<OpenPassTokens?>` from `openPassTokensValues()`

### Testing Patterns

Unit tests use `HTTPStub` (a `URLProtocol` subclass in `Tests/OpenPassTests/TestExtensions/`) to intercept `URLSession` requests. JSON fixtures live in `Tests/OpenPassTests/TestData/`. Use `HTTPStub.shared.stubIncludingDefaults(fixtures:)` which automatically stubs the JWKS and telemetry endpoints. `IDTokenValidationStub` provides `.valid`/`.invalid` stubs for token validation. `ImmediateClock` bypasses delays in `DeviceAuthorizationFlow` polling tests.

### Development App

Open `Development/OpenPassDevelopmentApp.xcodeproj` for manual testing. The Device Authorization flow requires a specific client ID — see `Development/README.md` for the `set-client-id.sh` helper script.

## Release Process

1. Set `openPassSdkVersion` in `Sources/OpenPass/OpenPassConfiguration.swift` to the release version
2. Create a GitHub Release with a tag matching the version
3. Bump `openPassSdkVersion` to the next minor version for future development
4. CocoaPods publishing is automated by CI workflow on release
