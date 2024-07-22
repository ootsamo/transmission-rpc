import Foundation

public enum TorrentState: DecodableWithConfiguration {
	/// Transfer has been paused.
	case stopped

	/// The torrent is queued for local data verification.
	case queuedForVerification

	/// The local data is being verified.
	case verifying

	/// The torrent is queued for download.
	case queuedForDownload

	/// The torrent is being downloaded.
	case downloading(eta: ETA)

	/// The torrent is queued for seeding.
	case queuedForSeeding

	/// The torrent is being seeded.
	case seeding(eta: ETA, timeUntilIdleLimit: ETA)

	public struct DecodingConfiguration {
		let eta: ETA
		let timeUntilIdleLimit: ETA
	}

	public init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
		let container = try decoder.singleValueContainer()
		let status = try container.decode(Int.self)
		switch status {
		case 0: self = .stopped
		case 1: self = .queuedForVerification
		case 2: self = .verifying
		case 3: self = .queuedForDownload
		case 4: self = .downloading(eta: configuration.eta)
		case 5: self = .queuedForSeeding
		case 6: self = .seeding(eta: configuration.eta, timeUntilIdleLimit: configuration.timeUntilIdleLimit)
		default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown torrent status value '\(status)'")
		}
	}
}
