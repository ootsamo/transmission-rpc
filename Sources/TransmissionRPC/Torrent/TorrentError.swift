import Foundation

public enum TorrentStatus: Decodable {
	case ok
	case error(TorrentError)

	enum CodingKeys: String, CodingKey, CaseIterable {
		case code = "error"
		case message = "errorString"
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let code = try container.decode(Int.self, forKey: .code)
		let message = try container.decodeIfPresent(String.self, forKey: .message)

		switch code {
		case 0: self = .ok
		case 1: self = .error(.localError(message: message))
		case 2: self = .error(.trackerError(message: message))
		case 3: self = .error(.trackerWarning(message: message))
		default:
			throw DecodingError.dataCorruptedError(
				forKey: .code,
				in: container,
				debugDescription: "Unknown torrent status value '\(code)'"
			)
		}
	}
}

public enum TorrentError: Error {
	case localError(message: String?)
	case trackerError(message: String?)
	case trackerWarning(message: String?)
}

extension TorrentError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .localError(message: let message), .trackerError(message: let message), .trackerWarning(message: let message):
			return message
		}
	}
}
