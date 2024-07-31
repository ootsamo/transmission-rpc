import Foundation

public class TransmissionClient {
	private static let minimumApiVersion = 16

	private let networking: Networking

	init(networking: Networking) {
		self.networking = networking
	}

	public convenience init(url: URL, credentials: Credentials? = nil) {
		self.init(networking: HTTPNetworking(url: url, credentials: credentials))
	}

	public convenience init(host: String, port: Int = 9091, path: String = "/transmission/rpc", credentials: Credentials? = nil) throws {
		var components = URLComponents()
		components.scheme = "http"
		components.host = host
		components.port = port
		components.path = path

		guard let url = components.url else {
			throw TransmissionError.invalidURLComponents
		}

		self.init(url: url, credentials: credentials)
	}

	@discardableResult
	private func send<T: Method>(method: T) async throws -> T.Response {
		if networking.apiVersion == nil {
			let apiVersion = try await networking.send(method: GetApiVersionMethod()).apiVersion
			if apiVersion < Self.minimumApiVersion {
				throw TransmissionError.unsupportedApiVersion(version: apiVersion)
			}
			networking.apiVersion = apiVersion
		}
		return try await networking.send(method: method)
	}

	public func getSession() async throws -> Session {
		try await send(method: GetSessionMethod()).session
	}

	public func getTorrents(_ filter: TorrentFilter = .all) async throws -> [Torrent] {
		try await send(method: GetTorrentMethod(filter: filter)).torrents
	}

	public func startTorrents(_ filter: TorrentFilter) async throws {
		try await send(method: StartTorrentMethod(filter: filter))
	}
}
