// swift-tools-version: 5.7

import PackageDescription

let package = Package(
	name: "transmission-rpc",
	platforms: [.macOS(.v13)],
	products: [
		.library(
			name: "TransmissionRPC",
			targets: ["TransmissionRPC"]
		)
	],
	targets: [
		.target(
			name: "TransmissionRPC"
		),
		.testTarget(
			name: "TransmissionRPCTests",
			dependencies: ["TransmissionRPC"]
		)
	]
)
