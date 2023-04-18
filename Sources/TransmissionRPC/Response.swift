enum Response<T: Decodable>: Decodable {
	case success(T)
	case failure(String)

	enum CodingKeys: CodingKey {
		case result
		case arguments
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let result = try container.decode(String.self, forKey: .result)

		switch result {
		case "success":
			self = .success(try container.decode(forKey: .arguments))
		default:
			self = .failure(result)
		}
	}
}
