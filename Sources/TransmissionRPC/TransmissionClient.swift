import Foundation

public class TransmissionClient {
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
			throw TransmissionError.invalidURL
		}

		self.init(url: url, credentials: credentials)
	}

	private func send<T: Method>(method: T) async throws -> T.Response {
		if networking.apiVersion == nil {
			let session = try await networking.send(method: GetSessionMethod()).session
			networking.apiVersion = session.apiVersion
		}
		return try await networking.send(method: method)
	}
}
