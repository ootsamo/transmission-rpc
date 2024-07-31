import Foundation

public struct TorrentProgress: DecodableWithConfiguration {
	enum CodingKeys: String, CodingKey, CaseIterable {
		case bytesUploaded = "uploadedEver"
		case bytesDownloaded = "downloadedEver"
		case bytesCorrupted = "corruptEver"
		case bytesUnchecked = "haveUnchecked"
		case bytesChecked = "haveValid"
		case bytesPending = "leftUntilDone"
		case bytesPendingAndAvailable = "desiredAvailable"
		case bytesWanted = "sizeWhenDone"
		case uploadRatio = "uploadRatio"
		case completeFraction = "percentComplete"
		case doneFraction = "percentDone"
		case recheckedFraction = "recheckProgress"
		case metadataCompleteFraction = "metadataPercentComplete"
		case pieceStatus = "pieces"
	}

	/// The total number of uploaded bytes.
	public let bytesUploaded: Int

	/// The total number of downloaded bytes.
	public let bytesDownloaded: Int

	/// The number of downloaded bytes that were corrupt.
	public let bytesCorrupted: Int

	/// The number of downloaded bytes that have not yet been validated against the corresponding piece hash.
	public let bytesUnchecked: Int

	/// The number of downloaded bytes that have been successfully validated against the corresponding piece hash.
	public let bytesChecked: Int

	/// Bytes left to download until all wanted files are complete.
	public let bytesPending: Int

	/// Bytes left to download until all wanted files are complete, including only those that are currently available from peers.
	public let bytesPendingAndAvailable: Int

	/// The total number of bytes in the files marked as wanted for download.
	public let bytesWanted: Int

	/// The ratio of uploaded bytes to downloaded bytes.
	public let uploadRatio: Double

	/// The fraction of the whole torrent that has been downloaded.
	@VersionRequirement(17)
	public var completeFraction: Double

	/// The fraction of wanted files that has been downloaded.
	public let doneFraction: Double

	/// The fraction of the torrent that has been rechecked. Has a value of zero if a recheck is not in progress.
	public let recheckedFraction: Double

	/// The fraction of the torrent's metadata that has been downloaded.
	public let metadataCompleteFraction: Double

	/// A list of boolean values indicating the download status of each piece in the torrent.
	public let pieceStatus: PieceStatus

	public init(from decoder: Decoder, configuration totalPieceCount: Int) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let apiVersion = decoder.userInfo[.apiVersion] as? Int
		bytesUploaded = try container.decode(forKey: .bytesUploaded)
		bytesDownloaded = try container.decode(forKey: .bytesDownloaded)
		bytesCorrupted = try container.decode(forKey: .bytesCorrupted)
		bytesUnchecked = try container.decode(forKey: .bytesUnchecked)
		bytesChecked = try container.decode(forKey: .bytesChecked)
		bytesPending = try container.decode(forKey: .bytesPending)
		bytesPendingAndAvailable = try container.decode(forKey: .bytesPendingAndAvailable)
		bytesWanted = try container.decode(forKey: .bytesWanted)
		uploadRatio = try container.decode(forKey: .uploadRatio)
		_completeFraction = try Self.completeFraction(apiVersion: apiVersion) {
			try container.decode(forKey: .completeFraction)
		}
		doneFraction = try container.decode(forKey: .doneFraction)
		recheckedFraction = try container.decode(forKey: .recheckedFraction)
		metadataCompleteFraction = try container.decode(forKey: .metadataCompleteFraction)
		pieceStatus = try container.decode(forKey: .pieceStatus, configuration: totalPieceCount)
	}
}
