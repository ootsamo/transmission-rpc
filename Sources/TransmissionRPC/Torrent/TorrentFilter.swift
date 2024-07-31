public enum TorrentFilter: ExpressibleByArrayLiteral, Encodable {
	case all
	case one(TorrentIdentifier)
	case multiple([TorrentIdentifier])
	case recentlyActive

	public init(arrayLiteral elements: TorrentIdentifier...) {
		if elements.count == 1 {
			self = .one(elements[0])
		} else {
			self = .multiple(elements)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .all:
			break
		case .one(let identifier):
			try container.encode(identifier)
		case .multiple(let identifiers):
			try container.encode(identifiers)
		case .recentlyActive:
			try container.encode("recently-active")
		}
	}
}
