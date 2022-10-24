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
    dependencies: [
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            .branch("master")
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "SPMTarget",
            dependencies: [
                .target(name: "ViafouraSDK", condition: .when(platforms: .some([.iOS]))),
                "KeychainAccess",
                "Kingfisher"
            ]
        ),
        .binaryTarget(
            name: "ViafouraSDK",
            path: "ViafouraSDK.xcframework"
        )
    ]
)
