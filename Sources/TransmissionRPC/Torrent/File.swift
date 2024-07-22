public struct File {
	enum CodingKeys: String, CodingKey, CaseIterable {
		case files
		case fileStats
	}

	private let info: FileInfo
	private let stats: FileStats

	/// The name of the file.
	public var name: String { info.name }

	/// The total number of bytes in the file.
	public var totalBytes: Int { info.bytesTotal }

	/// The number of downloaded bytes.
	public var completedBytes: Int { info.bytesCompleted }

	/// A boolean value indicating whether the file is wanted for download.
	public var wanted: Bool { stats.wanted }

	/// The download priority of the file.
	public var priority: Priority { stats.priority }

	static func files(from decoder: Decoder) throws -> [Self] {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let files = try container.decode([FileInfo].self, forKey: .files)
		let stats = try container.decode([FileStats].self, forKey: .fileStats)
		return zip(files, stats).map(Self.init)
	}
}

private struct FileInfo: Decodable {
	enum CodingKeys: String, CodingKey, CaseIterable {
		case name
		case bytesCompleted
		case bytesTotal = "length"
	}

	let name: String
	let bytesCompleted: Int
	let bytesTotal: Int
}

private struct FileStats: Decodable {
	enum CodingKeys: String, CodingKey {
		case priority
		case wanted
	}

	let priority: Priority
	let wanted: Bool
}
