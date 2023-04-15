public struct NetworkConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case peerPort = "peer-port"
		case randomizePeerPortOnStartup = "peer-port-random-on-start"
		case utpEnabled = "utp-enabled"
		case portForwardingEnabled = "port-forwarding-enabled"
	}

	/// The port used for incoming peer connections.
	public let peerPort: Int

	/// Indicates whether the peer port is chosen randomly on startup.
	public let randomizePeerPortOnStartup: Bool

	/// Indicates whether Micro Transport Protocol can be used instead of TCP.
	public let utpEnabled: Bool

	/// Indicates whether upstream router is asked to automatically forward the `peerPort` to Transmission using UPnP or NAT-PMP.
	public let portForwardingEnabled: Bool
}
