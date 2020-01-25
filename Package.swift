// swift-tools-version:5.1

import PackageDescription

private enum Defines {
    static let debugInspect = "DEBUG_INSPECT_ADDRS"
    static let useMemcpy = "USE_MEMCPY"
    static let useRawOffset = "USE_OFFSET_ARITHMETIC"
    static let zeroLength = "ZERO_LENGTH"
}

let package = Package(
    name: "flex-arr-mem",
    products: [
        .executable(
            name: "flex-arr-mem",
            targets: ["flex-arr-mem"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flex-arr-mem",
            dependencies: ["flex-arr-mem-layout"],
            // C defines for deps must be present in _both_ targets. (?!)
            cSettings: [.define(Defines.zeroLength)],
            swiftSettings: [
                .define(Defines.debugInspect),
                .define(Defines.useMemcpy),
                .define(Defines.zeroLength),
            ]
        ),
        .target(
            name: "flex-arr-mem-layout",
            dependencies: [],
            cSettings: [.define(Defines.zeroLength)]
        ),
    ]
)
