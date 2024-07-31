struct StartTorrentMethod: Method, Encodable {
	enum CodingKeys: String, CodingKey {
		case filter = "ids"
	}

	public static let name = "torrent-start"

	let filter: TorrentFilter
}
