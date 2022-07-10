// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ViafouraCore",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "ViafouraCore", targets: ["SPMTarget"])
    ],
    targets: [
        .binaryTarget(
            name: "ViafouraSDK",
            path: "ViafouraSDK.xcframework"
        ),
        .target(
            name: "SPMTarget",
            dependencies: [
                .target(name: "ViafouraSDK", condition: .when(platforms: .some([.iOS])))
            ]
        )
    ]
)
