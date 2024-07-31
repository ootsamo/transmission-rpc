struct Request<T: Method>: Encodable {
	enum CodingKeys: String, CodingKey {
		case method
		case arguments
	}

	let method: T

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(T.name, forKey: .method)
		try container.encode(method, forKey: .arguments)
	}
}
