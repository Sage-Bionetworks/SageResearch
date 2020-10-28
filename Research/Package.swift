// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SageResearch",
    defaultLocalization: "en",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_15),
        .iOS(.v11),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Research",
            targets: ["Research"]),
        .library(
            name: "ResearchUI",
            targets: ["ResearchUI"]),
        .library(
            name: "ResearchAudioRecorder",
            targets: ["ResearchAudioRecorder"]),
        .library(
            name: "ResearchMotion",
            targets: ["ResearchMotion"]),
        .library(
            name: "ResearchLocation",
            targets: ["ResearchLocation"]),
        .library(
            name: "Research_UnitTest",
            targets: ["Research_UnitTest", "NSLocale_Swizzle"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "JsonModel",
                 url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
                 from: "1.0.2"),
        
    ],
    targets: [

        // Research is the main target included in this repo. The "Formatters" and
        // "ExceptionHandler" targets are developed in Obj-c so they require a
        // separate target.
        .target(
            name: "Research",
            dependencies: ["JsonModel",
                           "ExceptionHandler",
                           "Formatters",
            ],
            resources: [
                .process("Resources"),
            ]),
        .target(name: "ExceptionHandler",
                dependencies: []),
        .target(name: "Formatters",
                dependencies: []),
        
        // ResearchUI currently only supports iOS devices. This includes views and view
        // controllers and references UIKit.
        .target(
            name: "ResearchUI",
            dependencies: [
                "Research",
            ],
            resources: [
                .process("PlatformContext/Resources"),
                .process("StepViewControllers/DefaultNibs"),
            ]),
        
        // ResearchAudioRecorder is used to allow recording dbFS level.
        .target(
            name: "ResearchAudioRecorder",
            dependencies: [
                "Research",
            ]),
        
        // ResearchMotion is used to allow recording dbFS level.
        .target(
            name: "ResearchMotion",
            dependencies: [
                "Research",
            ],
            resources: [
                .process("Resources"),
            ]),
        
        // ResearchLocation is used to allow location authorization and record distance
        // travelled.
        .target(
            name: "ResearchLocation",
            dependencies: [
                "Research",
                "ResearchMotion",
            ]),
        
        // The following targets are set up for unit testing.
        .target(
            name: "Research_UnitTest",
            dependencies: ["Research",
                           "ResearchUI"
            ]),
        .target(name: "NSLocale_Swizzle",
                dependencies: []),
        .testTarget(
            name: "ResearchTests",
            dependencies: [
                "Research",
                "Research_UnitTest",
                "NSLocale_Swizzle",
            ],
            resources: [
                .process("Resources"),
            ]
            ),
        .testTarget(
            name: "ResearchUITests",
            dependencies: ["ResearchUI"]),
        .testTarget(
            name: "ResearchMotionTests",
            dependencies: [
                "ResearchMotion",
                "Research_UnitTest",
            ]),
        .testTarget(
            name: "ResearchLocationTests",
            dependencies: [
                "ResearchLocation",
                "Research_UnitTest",
            ]),
        
    ]
)
