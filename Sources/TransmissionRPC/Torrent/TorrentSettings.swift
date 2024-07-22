public struct TorrentSettings: Decodable {
	enum CodingKeys: String, CodingKey, CaseIterable {
		case respectsSessionLimits = "honorsSessionLimits"
		case uploadLimit = "uploadLimit"
		case uploadLimited = "uploadLimited"
		case downloadLimit = "downloadLimit"
		case downloadLimited = "downloadLimited"
		case peerLimit = "peer-limit"

		case bandwidthPriority = "bandwidthPriority"
		case isSequentialDownload = "sequentialDownload"

		case seedIdleLimit = "seedIdleLimit"
		case seedIdleMode = "seedIdleMode"
		case seedRatioLimit = "seedRatioLimit"
		case seedRatioMode = "seedRatioMode"
	}

	/// A boolean value indicating whether the torrent is affected by global transfer rate limits.
	public let respectsSessionLimits: Bool

	/// The upload rate limit.
	public let uploadLimit: TransferRateLimit

	/// The download rate limit.
	public let downloadLimit: TransferRateLimit

	/// The maximum number of connected peers.
	public let peerLimit: Int

	/// The bandwidth priority of the torrent.
	public let bandwidthPriority: Int

	/// A boolean value indicating whether the torrent downloads pieces in sequential order.
	public let isSequentialDownload: Int

	/// The limit for the number of minutes the torrent is allowed to be idle before seeding is stopped.
	public let seedIdleLimit: SeedLimit<Int>

	/// The limit for the upload ratio the torrent is allowed to reach before seeding is stopped.
	public let seedRatioLimit: SeedLimit<Double>

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		respectsSessionLimits = try container.decode(forKey: .respectsSessionLimits)
		uploadLimit = TransferRateLimit(
			value: try container.decode(forKey: .uploadLimit),
			isEnabled: try container.decode(forKey: .uploadLimited)
		)
		downloadLimit = TransferRateLimit(
			value: try container.decode(forKey: .downloadLimit),
			isEnabled: try container.decode(forKey: .downloadLimited)
		)
		peerLimit = try container.decode(forKey: .peerLimit)
		bandwidthPriority = try container.decode(forKey: .bandwidthPriority)
		isSequentialDownload = try container.decode(forKey: .isSequentialDownload)

		seedIdleLimit = SeedLimit<Int>(
			mode: try container.decode(forKey: .seedIdleMode),
			value: try container.decode(forKey: .seedIdleLimit)
		)

		seedRatioLimit = SeedLimit<Double>(
			mode: try container.decode(forKey: .seedRatioMode),
			value: try container.decode(forKey: .seedRatioLimit)
		)
	}
}

public struct TransferRateLimit {
	/// The transfer rate limit, in kilobytes per second.
	public let value: Int

	/// A boolean value indicating whether the transfer rate limit is enabled.
	public let isEnabled: Bool
}
