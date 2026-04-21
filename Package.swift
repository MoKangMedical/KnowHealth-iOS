// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KnowHealth",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KnowHealth", targets: ["KnowHealth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    ],
    targets: [
        .target(
            name: "KnowHealth",
            dependencies: ["Alamofire"],
            path: "Sources/KnowHealth"
        )
    ]
)
