// swift-tools-version: 5.8
//
//  Package.swift
//  Dash the Fox
//
//  Swift Package Manager configuration for the iOS app.
//  Targets iOS 15.0+ on iPad and iPhone.
//

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Dash the Fox",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .iOSApplication(
            name: "Dash the Fox",
            targets: ["AppModule"],
            bundleIdentifier: "com.dashthefox.game",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .dog),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
