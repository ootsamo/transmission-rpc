struct GetSessionMethod: Method, Encodable {
	typealias Response = GetSessionResponse

	static let name = "session-get"
}

struct GetSessionResponse: Decodable {
	let session: Session

	init(from decoder: Decoder) throws {
		session = try Session(from: decoder)
	}
}
