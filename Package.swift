// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenMind",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ZenMind",
            targets: ["ZenMind"]
        )
    ],
    targets: [
        .target(
            name: "ZenMind",
            path: "ZenMind"
        )
    ]
)