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
    dependencies: [
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            .exact("4.2.2")
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            .exact("7.4.0")
        )
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
