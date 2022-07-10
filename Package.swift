// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ViafouraCore",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "ViafouraCore")
    ],
    targets: [
        .binaryTarget(
            name: "ViafouraCore",
            path: "ViafouraCore.xcframework"
        )
    ]
)
