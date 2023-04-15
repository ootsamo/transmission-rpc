import Foundation

public struct PeerConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case encryption = "encryption"
		case dhtEnabled = "dht-enabled"
		case lpdEnabled = "lpd-enabled"
		case globalPeerLimit = "peer-limit-global"
		case transferPeerLimit = "peer-limit-per-torrent"
		case pexEnabled = "pex-enabled"
	}

	/// Metadata for the list of blocked peers.
	public let blocklistInfo: PeerBlocklistInfo

	/// Configuration to require, prefer or tolerate peers that support encryption.
	public let encryption: PeerEncryptionConfiguration

	/// Indicates whether Distributed Hash Table can be used for peer discovery.
	public let dhtEnabled: Bool

	/// Indicates whether Local Peer Discovery can be used.
	public let lpdEnabled: Bool

	/// Indicates whether Peer Exchange can be used for peer discovery.
	public let pexEnabled: Bool

	/// The maximum number of connected peers across all transfers.
	public let globalPeerLimit: Int

	/// The maximum number of connected peers for each transfer.
	public let transferPeerLimit: Int

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		blocklistInfo = try PeerBlocklistInfo(from: decoder)
		encryption = try container.decode(PeerEncryptionConfiguration.self, forKey: .encryption)
		dhtEnabled = try container.decode(Bool.self, forKey: .dhtEnabled)
		lpdEnabled = try container.decode(Bool.self, forKey: .lpdEnabled)
		pexEnabled = try container.decode(Bool.self, forKey: .pexEnabled)
		globalPeerLimit = try container.decode(Int.self, forKey: .globalPeerLimit)
		transferPeerLimit = try container.decode(Int.self, forKey: .transferPeerLimit)
	}
}

public struct PeerBlocklistInfo: Decodable {
	enum CodingKeys: String, CodingKey {
		case url = "blocklist-url"
		case enabled = "blocklist-enabled"
		case ruleCount = "blocklist-size"
	}

	/// The blocklist URL.
	public let url: URL

	/// Indicates whether the blocklist is enabled.
	public let enabled: Bool

	/// The number of rules in the blocklist.
	public let ruleCount: Int

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		url = try container.decode(URL.self, forKey: .url)
		enabled = try container.decode(Bool.self, forKey: .enabled)
		ruleCount = try container.decode(Int.self, forKey: .ruleCount)
	}
}

public enum PeerEncryptionConfiguration: Decodable {
	/// Only encrypted peer connections are allowed.
	case required

	/// Encrypted peers are used if available.
	case preferred

	/// Unencrypted peers are allowed.
	case tolerated

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(String.self)
		switch value {
		case "required": self = .required
		case "preferred": self = .preferred
		case "tolerated": self = .tolerated
		default:
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown peer encryption setting '\(value)'")
		}
	}
}
