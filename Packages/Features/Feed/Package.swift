// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feed",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Feed",
            targets: ["Feed"]),
    ],
    dependencies: [
        .package(path: "../Core/Data"),
        .package(path: "../Core/Utilities"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Feed",
            dependencies: ["Data", "Utilities"]),
        .testTarget(
            name: "FeedTests",
            dependencies: ["Feed"]),
    ]
)
