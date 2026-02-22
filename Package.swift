// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FoshLabsNavigationKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FoshLabsNavigationKit",
            targets: ["FoshLabsNavigationKit"]
        ),
    ],
    targets: [
        .target(
            name: "FoshLabsNavigationKit",
            path: "Sources/FoshLabsNavigationKit"
        ),
        .testTarget(
            name: "FoshLabsNavigationKitTests",
            dependencies: ["FoshLabsNavigationKit"],
            path: "Tests/FoshLabsNavigationKitTests"
        ),
    ]
)
