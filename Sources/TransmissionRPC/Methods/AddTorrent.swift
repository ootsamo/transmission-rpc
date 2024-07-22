import Foundation

struct AddTorrentMethod: Method, Encodable {
	typealias Response = AddTorrentResponse

	enum CodingKeys: String, CodingKey {
		case downloadDirectory = "download-dir"
	}

	public static let name = "torrent-add"

	let source: AddTorrentSource
	let downloadDirectory: String?

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(self.downloadDirectory, forKey: .downloadDirectory)
		try source.encode(to: encoder)
	}
}

public enum AddTorrentSource: Encodable {
	case url(URL)
	case filename(String)
	case metainfo(String)

	enum CodingKeys: String, CodingKey {
		case filename
		case metainfo
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .url(let url):
			try container.encode(url.absoluteString, forKey: .filename)
		case .filename(let filename):
			try container.encode(filename, forKey: .filename)
		case .metainfo(let metainfo):
			try container.encode(metainfo, forKey: .metainfo)
		}
	}
}

struct AddTorrentResponse: Decodable {}
