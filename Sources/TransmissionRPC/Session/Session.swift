import Foundation

public struct Session: Decodable {
	enum CodingKeys: String, CodingKey {
		case units
	}

	public let units: SessionUnits

	/// List of default tracker URLs.
	@VersionRequirement(17)
	public var defaultTrackers: TrackerConfiguration

	/// Configuration for peer limits and connection information.
	public let peerConfiguration: PeerConfiguration

	/// Configuration to specify simultaneous transfer limits and other behavior.
	public let transferConfiguration: TransferConfiguration

	/// Configuration to limit upload and download speeds.
	public let bandwidthConfiguration: BandwidthConfiguration

	/// Configuration for seeding limits.
	public let seedingConfiguration: SeedingConfiguration

	/// Configuration for scripts triggered by transfer events.
	public let scriptConfiguration: ScriptConfiguration

	/// Information about the Transmission version.
	public let versionInformation: VersionInformation

	public init(from decoder: Decoder) throws {
		let apiVersion = decoder.userInfo[.apiVersion] as? Int
		let container = try decoder.container(keyedBy: CodingKeys.self)

		units = try container.decode(forKey: .units)
		_defaultTrackers = try Self.defaultTrackers(apiVersion: apiVersion) {
			try TrackerConfiguration(from: decoder)
		}
		peerConfiguration = try PeerConfiguration(from: decoder)
		transferConfiguration = try TransferConfiguration(from: decoder)
		bandwidthConfiguration = try BandwidthConfiguration(from: decoder, configuration: units)
		seedingConfiguration = try SeedingConfiguration(from: decoder)
		scriptConfiguration = try ScriptConfiguration(from: decoder)
		versionInformation = try VersionInformation(from: decoder)
	}
}
