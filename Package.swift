// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ViafouraCore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "ViafouraCore", targets: ["SPMTarget"])
    ],
    targets: [
        .target(
            name: "SPMTarget",
            dependencies: [
                .target(name: "ViafouraSDK"),
                "KeychainAccess",
                "Kingfisher"
            ],
            path: "Sources/SPMTarget",
            publicHeadersPath: ""
        ),
        .binaryTarget(
            name: "ViafouraSDK",
            path: "ViafouraSDK.xcframework"
        )
    ]
)
