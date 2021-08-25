// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "DangerXibAssets",
    products: [
        .library(
            name: "DangerXibAssets",
            targets: ["DangerXibAssets"]),
    ],
    dependencies: [
        .package(name: "danger-swift",url: "https://github.com/danger/swift", .upToNextMajor(from: "3.0.0")),
        .package(name: "IBDecodable", url: "https://github.com/IBDecodable/IBDecodable.git", .upToNextMinor(from: "0.4.3"))
    ],
    targets: [
        .target(
            name: "DangerXibAssets",
            dependencies: [
                "IBDecodable",
                .product(name: "Danger", package: "danger-swift")
            ]),
        .testTarget(
            name: "DangerXibAssetsTests",
            dependencies: ["DangerXibAssets"]),
    ]
)
