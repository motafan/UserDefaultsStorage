// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserDefaultsStorage",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v14),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UserDefaultsStorage",
            targets: ["UserDefaultsStorage"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UserDefaultsStorage"),
        .testTarget(
            name: "UserDefaultsStorageTests",
            dependencies: ["UserDefaultsStorage"]
        ),
    ]
)
