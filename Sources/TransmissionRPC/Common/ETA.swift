public enum ETA: Decodable {
	case duration(Duration)
	case notAvailable
	case unknown

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		switch try container.decode(Int.self) {
		case -1: self = .notAvailable
		case -2: self = .unknown
		case let value: self = .duration(.seconds(value))
		}
	}
}
