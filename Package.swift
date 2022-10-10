// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenPass",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "OpenPass",
            targets: ["OpenPass"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenPass",
            dependencies: []),
    ]
)
