struct GetApiVersionMethod: Method, Encodable {
	typealias Response = GetApiVersionResponse

	static let name = "session-get"
}

struct GetApiVersionResponse: Decodable {
	enum CodingKeys: String, CodingKey {
		case apiVersion = "rpc-version"
	}

	public let apiVersion: Int
}
