public struct MagnetURI: Decodable {
	/// The URI string.
	public let string: String

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		string = try container.decode(String.self)
	}
}
