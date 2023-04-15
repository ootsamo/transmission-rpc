struct GetSessionMethod: Method, Encodable {
	typealias Response = GetSessionResponse

	static let name = "session-get"

	let fields = Session.CodingKeys.allCases
}

public struct GetSessionResponse: Decodable {
	public let session: Session

	public init(from decoder: Decoder) throws {
		session = try Session(from: decoder)
	}
}
