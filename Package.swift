// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenPass",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "OpenPass",
            targets: ["OpenPass"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenPass",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OpenPassTests",
            dependencies: ["OpenPass"],
            resources: [
                .copy("TestData")
            ]
        )
    ]
)
