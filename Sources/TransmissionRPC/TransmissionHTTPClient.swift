import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class TransmissionHTTPClient: TransmissionClient {
	private let url: URL
	private let urlSession: URLSession
	private let jsonEncoder: JSONEncoder
	private let jsonDecoder: JSONDecoder

	init(url: URL, urlSession: URLSession) {
		self.url = url
		self.urlSession = urlSession
		self.jsonEncoder = JSONEncoder()
		self.jsonDecoder = JSONDecoder()
	}

	public convenience init(url: URL) {
		self.init(url: url, urlSession: .shared)
	}

	public convenience init(host: String, port: Int = 9091, path: String = "/transmission/rpc") throws {
		var components = URLComponents()
		components.scheme = "http"
		components.host = host
		components.port = port
		components.path = path

		guard let url = components.url else {
			throw TransmissionClientError.invalidURL
		}

		self.init(url: url)
	}

	public func send<T: Method>(method: T) async throws -> T.Response {
		let request = Request(method: method)
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = "POST"
		urlRequest.httpBody = try jsonEncoder.encode(request)
		let (data, _) = try await urlSession.data(for: urlRequest)
		let response = try jsonDecoder.decode(Response<T.Response>.self, from: data)

		switch response {
		case .success(let object): return object
		case .failure(let message): throw TransmissionClientError.failureResponse(message)
		}
	}
}

public enum TransmissionClientError: LocalizedError {
	case invalidURL
	case failureResponse(String)

	public var errorDescription: String? {
		switch self {
		case .invalidURL: return "Unable to create a valid URL from the provided components."
		case .failureResponse(let message): return message
		}
	}
}
