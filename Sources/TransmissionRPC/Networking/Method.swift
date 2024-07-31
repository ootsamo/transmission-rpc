protocol Method: Encodable {
	associatedtype Response: Decodable = EmptyResponse

	static var name: String { get }
}

struct EmptyResponse: Decodable {}
