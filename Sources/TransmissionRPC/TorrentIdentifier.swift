public enum TorrentIdentifier: ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, Encodable {
	case id(Int)
	case hash(String)

	public init(integerLiteral value: IntegerLiteralType) {
		self = .id(value)
	}

	public init(stringLiteral value: String) {
		self = .hash(value)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .id(let id): try container.encode(id)
		case .hash(let hash): try container.encode(hash)
		}
	}
}
