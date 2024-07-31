struct StopTorrentMethod: Method, Encodable {
	enum CodingKeys: String, CodingKey {
		case filter = "ids"
	}

	public static let name = "torrent-stop"

	let filter: TorrentFilter
}
