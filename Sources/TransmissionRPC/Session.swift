public struct Session: Decodable {
	enum CodingKeys: String, CodingKey, CaseIterable, Encodable {
		case apiVersion = "rpc-version"
	}

	public let apiVersion: Int
}
