# OpenPass iOS SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5-orange)](https://img.shields.io/badge/Swift-5-orange)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-blue)](https://img.shields.io/badge/Swift_Package_Manager-compatible-blue)

## Repository Structure

```
.
├── Development
│   ├── OpenPassDevelopmentApp
│   └── OpenPassDevelopmentApp.xcodeproj
├── Package.swift
├── README.md
├── Sources
│   └── OpenPass
└── Tests
    └── OpenPassTests
```

## Requirements

* Xcode 14.0+

| Platform | Minimum target |
| --- | --- |
| iOS | 13.0+ |

## Development

The OpenPass SDK is a standalone headless library defined and managed by the Swift Package Manager via `Package.swift`.  As such the `OpenPassDevelopmentApp` is the primary way for developing the SDK.  Use Xcode to open `Development/OpenPassDevelopmentApp/OpenPassDevelopmentApp.xcodeproj` to begin development.
