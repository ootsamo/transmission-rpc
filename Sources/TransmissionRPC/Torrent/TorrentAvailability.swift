public struct TorrentAvailability: Decodable {
	enum PieceStatus {
		case downloaded
		case unavailable
		case available(peerCount: Int)
	}

	let pieces: [PieceStatus]

	init() { pieces = [] }

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let pieceInfo = try container.decode([Int].self)
		pieces = pieceInfo.map {
			switch $0 {
			case -1: return .downloaded
			case 0: return .unavailable
			default: return .available(peerCount: $0)
			}
		}
	}
}
