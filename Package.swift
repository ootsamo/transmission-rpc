// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
	name: "transmission-rpc",
	platforms: [.macOS(.v13)],
	products: [
		.library(
			name: "TransmissionRPC",
			targets: ["TransmissionRPC"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax", from: "510.0.0")
	],
	targets: [
		.target(
			name: "TransmissionRPC",
			dependencies: ["TransmissionMacros"]
		),
		.testTarget(
			name: "TransmissionRPCTests",
			dependencies: ["TransmissionRPC"]
		),
		.macro(
			name: "TransmissionMacros",
			dependencies: [
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax")
			]
		)
	]
)
