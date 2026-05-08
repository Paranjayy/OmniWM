// swift-tools-version: 6.2
import Foundation
import PackageDescription

let package = Package(
    name: "OmniWM",
    platforms: [
        .macOS("15.0")
    ],
    products: [
        .executable(
            name: "omniwmctl",
            targets: ["OmniWMCtl"]
        )
    ],
    targets: [
        .target(
            name: "OmniWMIPC",
            path: "Sources/OmniWMIPC",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .executableTarget(
            name: "OmniWMCtl",
            dependencies: ["OmniWMIPC"],
            path: "Sources/OmniWMCtl",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
