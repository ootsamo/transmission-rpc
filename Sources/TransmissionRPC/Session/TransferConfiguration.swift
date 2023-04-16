public struct TransferConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case startAddedTransfers = "start-added-torrents"
		case seedQueueEnabled = "seed-queue-enabled"
		case seedQueueSize = "seed-queue-size"
		case downloadQueueEnabled = "download-queue-enabled"
		case downloadQueueSize = "download-queue-size"
		case ignoreStalled = "queue-stalled-enabled"
		case stalledIgnoreLimitMinutes = "queue-stalled-minutes"
	}

	/// Indicates whether new transfers are started immediately after they are added.
	public let startAddedTransfers: Bool

	/// Indicates whether the limit for the number of simultaneous uploads is enabled.
	public let seedQueueEnabled: Bool

	/// The number of uploads allowed simultaneously.
	public let seedQueueSize: Int

	/// Indicates whether the limit for the number of simultaneous downloads is enabled.
	public let downloadQueueEnabled: Bool

	/// The number of downloads allowed simultaneously.
	public let downloadQueueSize: Int

	/// If `true`, transfers that have been idle for the duration specified  in `stalledIgnoreLimitMinutes` won't occupy a slot in the upload / download queues.
	public let ignoreStalled: Bool

	/// The number of minutes a transfer must be idle before it is considered stalled and ignored when considering upload / download queues.
	public let stalledIgnoreLimitMinutes: Int
}
