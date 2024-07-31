protocol Method: Encodable {
	associatedtype Response: Decodable

	static var name: String { get }
}
