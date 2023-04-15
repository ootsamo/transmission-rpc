public struct ScriptConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case transferAddedEnabled = "script-torrent-added-enabled"
		case transferAddedFilename = "script-torrent-added-filename"
		case transferDoneDownloadingEnabled = "script-torrent-done-enabled"
		case transferDoneDownloadingFilename = "script-torrent-done-filename"
		case transferDoneSeedingEnabled = "script-torrent-done-seeding-enabled"
		case transferDoneSeedingFilename = "script-torrent-done-seeding-filename"
	}

	public struct Script {
		let enabled: Bool
		let path: String

		init(from decoder: Decoder, enabledKey: CodingKeys, pathKey: CodingKeys) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			enabled = try container.decode(Bool.self, forKey: enabledKey)
			path = try container.decode(String.self, forKey: pathKey)
		}
	}

	/// The script to run when a new transfer is added.
	public var transferAdded: Script { get throws { try _optionalTransferAdded.unwrappedValue }}
	@ApiVersionRequirement var optionalTransferAdded: Script?

	/// The script to run when a transfer finishes downloading.
	public let transferDoneDownloading: Script

	/// The script to run when a transfer finishes seeding.
	public var transferDoneSeeding: Script { get throws { try _optionalTransferDoneSeeding.unwrappedValue }}
	@ApiVersionRequirement var optionalTransferDoneSeeding: Script?

	public init(from decoder: Decoder) throws {
		let apiVersion = decoder.userInfo[.apiVersion] as? Int
		_optionalTransferAdded = try ApiVersionRequirement(current: apiVersion, required: 17) {
			try Script(
				from: decoder,
				enabledKey: .transferAddedEnabled,
				pathKey: .transferAddedFilename
			)
		}
		transferDoneDownloading = try Script(
			from: decoder,
			enabledKey: .transferDoneDownloadingEnabled,
			pathKey: .transferDoneDownloadingFilename
		)
		_optionalTransferDoneSeeding = try ApiVersionRequirement(current: apiVersion, required: 17) {
			try Script(
				from: decoder,
				enabledKey: .transferDoneSeedingEnabled,
				pathKey: .transferDoneSeedingFilename
			)
		}
	}
}
