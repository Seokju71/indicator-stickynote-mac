// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StickyNotes",
    platforms: [
        .macOS(.v13) // Target macOS 13 (Ventura) for compatibility
    ],
    products: [
        .executable(
            name: "StickyNotes",
            targets: ["StickyNotes"]),
    ],
    targets: [
        .executableTarget(
            name: "StickyNotes",
            path: "Sources/StickyNotes"),
    ]
)
