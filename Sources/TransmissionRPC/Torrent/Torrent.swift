import Foundation

public struct Torrent: Decodable {
	enum CodingKeys: String, CodingKey, CaseIterable {
		case id = "id"
		case hash = "hashString"
		case magnetURI = "magnetLink"
		case name = "name"
		case group = "group"
		case labels = "labels"
		case comment = "comment"
		case creator = "creator"
		case primaryMimeType = "primary-mime-type"
		case creationDate = "dateCreated"
		case editDate = "editDate"
		case startDate = "startDate"
		case doneDate = "doneDate"
		case torrentFilePath = "torrentFile"
		case downloadDirectoryPath = "downloadDir"
		case totalBytes = "totalSize"
		case totalPieceCount = "pieceCount"
		case pieceSize = "pieceSize"
		case trackers = "trackerStats"
		case nextAllowedAnnounceTime = "manualAnnounceTime"
		case peers = "peers"
		case peerSources = "peersFrom"
		case webSeedCount = "webseeds"
		case activeWebSeedCount = "webseedsSendingToUs"
		case queuePosition = "queuePosition"
		case state = "status"
		case availability = "availability"
		case uploadRate = "rateUpload"
		case downloadRate = "rateDownload"
		case secondsDownloading = "secondsDownloading"
		case secondsUploading = "secondsSeeding"
		case etaSeconds = "eta"
		case secondsUntilIdleLimit = "etaIdle"
		case isFinished = "isFinished"
		case isPrivate = "isPrivate"
		case isStalled = "isStalled"
	}

	/// The local identifier of the torrent.
	public let id: Int

	/// The SHA1 info hash of the torrent.
	public let hash: String

	/// A magnet URI describing the torrent.
	public let magnetURI: MagnetURI

	/// The local name of the torrent.
	public let name: String

	/// The transfer settings for the torrent.
	public let settings: TorrentSettings

	/// The group the torrent is assigned to.
	@VersionRequirement(17)
	public var group: String

	/// A list of labels assigned to the torrent.
	public let labels: [String]

	/// A local comment for the torrent.
	public let comment: String

	/// The creator of the torrent.
	public let creator: String

	/// The primary MIME type of the files in the torrent.
	@VersionRequirement(17)
	public var primaryMimeType: String

	/// The date the torrent was created.
	public let creationDate: Date?

	/// The date the torrent was last edited.
	public let editDate: Date?

	/// The date the torrent transfer was started.
	public let startDate: Date?

	/// The date the torrent finished downloading.
	public let doneDate: Date?

	/// A path to the torrent file.
	public let torrentFilePath: String

	/// A path to the download directory.
	public let downloadDirectoryPath: String

	/// The total size of all files in the torrent, in bytes.
	public let totalBytes: Int

	/// The number of pieces in the torrent.
	public let totalPieceCount: Int

	/// The size of each piece in the torrent, in bytes.
	public let pieceSize: Int

	/// A list of trackers assigned to the torrent.
	public let trackers: [Tracker]

	/// The next time more peers can be requested.
	public let nextAllowedAnnounceTime: Date?

	/// A list of files included in the torrent.
	public let files: [File]

	/// Availability information for each piece of the torrent.
	@VersionRequirement(17)
	public var availability: TorrentAvailability

	/// The current state of the torrent.
	public let state: TorrentState

	/// The status of the torrent, indicating whether an error has occurred or not.
	public let status: TorrentStatus

	/// The transfer progress of the torrent.
	public let progress: TorrentProgress

	/// The position of the torrent in the transfer queue.
	public let queuePosition: Int

	/// The number of seconds spent downloading the torrent.
	public let secondsDownloading: Int

	/// The number of seconds spent uploading the torrent.
	public let secondsUploading: Int

	/// The current transfer rates for the torrent.
	public let transferRates: TransferRates

	/// A boolean value indicating whether the seed ratio limit has been reached.
	public let isFinished: Bool

	/// A boolean value indicating whether the torrent uses a private tracker.
	public let isPrivate: Bool

	/// A boolean value indicating whether the torrent has been idle for long enough to be considered stalled.
	public let isStalled: Bool

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let apiVersion = decoder.userInfo[.apiVersion] as? Int
		id = try container.decode(forKey: .id)
		hash = try container.decode(forKey: .hash)
		magnetURI = try container.decode(forKey: .magnetURI)
		name = try container.decode(forKey: .name)
		settings = try TorrentSettings(from: decoder)
		_group = try Self.group(apiVersion: apiVersion) {
			try container.decode(forKey: .group)
		}
		labels = try container.decode(forKey: .labels)
		comment = try container.decode(forKey: .comment)
		creator = try container.decode(forKey: .creator)
		_primaryMimeType = try Self.primaryMimeType(apiVersion: apiVersion) {
			try container.decode(forKey: .primaryMimeType)
		}
		creationDate = try container.decode(forKey: .creationDate)
		editDate = try container.decode(forKey: .editDate)
		startDate = try container.decode(forKey: .startDate)
		doneDate = try container.decode(forKey: .doneDate)
		torrentFilePath = try container.decode(forKey: .torrentFilePath)
		downloadDirectoryPath = try container.decode(forKey: .downloadDirectoryPath)
		totalBytes = try container.decode(forKey: .totalBytes)
		totalPieceCount = try container.decode(forKey: .totalPieceCount)
		pieceSize = try container.decode(forKey: .pieceSize)

		trackers = try container.decode(forKey: .trackers)
		nextAllowedAnnounceTime = try container.decode(forKey: .nextAllowedAnnounceTime)

		files = try File.files(from: decoder)
		_availability = try Self.availability(apiVersion: apiVersion) {
			try container.decode(forKey: .availability)
		}
		state = try container.decode(forKey: .state, configuration: .init(
			eta: container.decode(forKey: .etaSeconds),
			timeUntilIdleLimit: container.decode(forKey: .secondsUntilIdleLimit)
		))
		status = try TorrentStatus(from: decoder)
		progress = try TorrentProgress(from: decoder, configuration: totalPieceCount)
		queuePosition = try container.decode(forKey: .queuePosition)
		secondsDownloading = try container.decode(forKey: .secondsDownloading)
		secondsUploading = try container.decode(forKey: .secondsUploading)
		transferRates = TransferRates(
			up: try container.decode(forKey: .uploadRate),
			down: try container.decode(forKey: .downloadRate)
		)
		isFinished = try container.decode(forKey: .isFinished)
		isPrivate = try container.decode(forKey: .isPrivate)
		isStalled = try container.decode(forKey: .isStalled)
	}
}

public struct SeedLimit<T> {
	public enum Mode: Decodable {
		case followGlobal
		case untilValue
		case unlimited

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			let value = try container.decode(Int.self)
			switch value {
			case 0: self = .followGlobal
			case 1: self = .untilValue
			case 2: self = .unlimited
			default:
				throw DecodingError.dataCorruptedError(
					in: container,
					debugDescription: "Unknown seed limit mode value '\(value)"
				)
			}
		}
	}

	public let mode: Mode
	public let value: T
}
