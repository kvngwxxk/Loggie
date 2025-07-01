// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Loggie",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Loggie", targets: ["Loggie"]),
        .library(name: "LoggieNetwork", targets: ["LoggieNetwork"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "Loggie"
        ),
        .target(
            name: "LoggieNetwork",
            dependencies: [
                "Loggie",
                "Alamofire"
            ],
            path: "Sources/LoggieNetwork",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("CoreData"),
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "LoggieTests",
            dependencies: ["Loggie"]
        ),
        .testTarget(
            name: "LoggieNetworkTests",
            dependencies: ["LoggieNetwork"]
        )
    ]
)
