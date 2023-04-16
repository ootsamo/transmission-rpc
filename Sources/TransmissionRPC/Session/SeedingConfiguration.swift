public struct SeedingConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case idleLimitMinutes = "idle-seeding-limit"
		case idleLimitEnabled = "idle-seeding-limit-enabled"
		case ratioLimit = "seedRatioLimit"
		case ratioLimitEnabled = "seedRatioLimited"
	}

	/// Number of minutes to wait before stopping seeding if there are no peers connected.
	public let idleLimitMinutes: Int

	/// Indicates whether seeding is stopped if the transfer stays idle for the duration specified in `idleLimitMinutes`.
	public let idleLimitEnabled: Bool

	/// The ratio of uploaded to downloaded data to reach before stopping seeding.
	public let ratioLimit: Double

	/// Indicates whether seeding is stopped when `ratioLimit` is reached.
	public let ratioLimitEnabled: Bool
}
