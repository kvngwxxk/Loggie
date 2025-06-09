// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Loggie",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Loggie", targets: ["Loggie"]),
        .library(name: "LoggieNetwork", targets: ["LoggieNetwork"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0")
    ],
    targets: [
        .target(name: "Loggie"),
        .target(
            name: "LoggieNetwork",
            dependencies: [
                "Loggie",
                "Alamofire"
            ],
            path: "Sources/LoggieNetwork",
            resources: [
              .process("Resources/LoggieNetworkLogModel.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "LoggieTests",
            dependencies: ["Loggie"]
        )
    ]
)
