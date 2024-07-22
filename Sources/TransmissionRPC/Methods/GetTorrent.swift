struct GetTorrentMethod: Method, Encodable {
	typealias Response = GetTorrentResponse

	enum CodingKeys: String, CodingKey {
		case filter = "ids"
		case fields
	}

	static let name = "torrent-get"

	private static let fields = Array([
		Torrent.CodingKeys.strings,
		TorrentProgress.CodingKeys.strings,
		TorrentStatus.CodingKeys.strings,
		TorrentSettings.CodingKeys.strings,
		TorrentSettings.CodingKeys.strings,
		File.CodingKeys.strings
	].joined())

	let filter: TorrentFilter

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(filter, forKey: .filter)

		try container.encode(Self.fields, forKey: .fields)
	}
}

private extension CodingKey where Self: CaseIterable {
	static var strings: [String] {
		allCases.map(\.stringValue)
	}
}

struct GetTorrentResponse: Decodable {
	let torrents: [Torrent]
}

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
