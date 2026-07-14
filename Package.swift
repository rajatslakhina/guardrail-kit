// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "GuardrailKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "GuardrailKit", targets: ["GuardrailKit"]),
        .executable(name: "GuardrailKitDemo", targets: ["GuardrailKitDemo"])
    ],
    targets: [
        .target(
            name: "GuardrailKit"
        ),
        .executableTarget(
            name: "GuardrailKitDemo",
            dependencies: ["GuardrailKit"]
        ),
        .testTarget(
            name: "GuardrailKitTests",
            dependencies: ["GuardrailKit"]
        )
    ]
)
