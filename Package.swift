// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "acaia-swift",
    products: [
        .library(
            name: "AcaiaProtocol",
            targets: ["AcaiaProtocol"]
        ),
    ],
    targets: [
        .target(name: "AcaiaProtocol"),
        .testTarget(
            name: "AcaiaProtocolTests",
            dependencies: ["AcaiaProtocol"]
        ),
    ]
)
