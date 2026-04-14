// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KnowHealth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "KnowHealth", targets: ["KnowHealth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
    ],
    targets: [
        .target(
            name: "KnowHealth",
            dependencies: ["Alamofire", "Kingfisher"],
            path: "Sources/KnowHealth",
            resources: [
                .process("../Resources")
            ]
        ),
        .testTarget(
            name: "KnowHealthTests",
            dependencies: ["KnowHealth"],
            path: "Tests"
        ),
    ]
)
