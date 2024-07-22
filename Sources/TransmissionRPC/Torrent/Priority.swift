public enum Priority: Decodable {
	case low
	case normal
	case high

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(Int.self)
		switch value {
		case -1: self = .low
		case 0: self = .normal
		case 1: self = .high
		default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown priority value \(value)")
		}
	}
}
