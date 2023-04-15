import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class TransmissionHTTPClient: TransmissionClient {
	enum HeaderName {
		static let sessionId = "X-Transmission-Session-Id"
		static let authorization = "Authorization"
	}

	private let url: URL
	private let credentials: Credentials?
	private let urlSession: URLSession
	private let jsonEncoder: JSONEncoder
	private let jsonDecoder: JSONDecoder

	private var sessionId: String?

	init(url: URL, credentials: Credentials?, urlSession: URLSession) {
		self.url = url
		self.credentials = credentials
		self.urlSession = urlSession
		self.jsonEncoder = JSONEncoder()
		self.jsonDecoder = JSONDecoder()
	}

	public convenience init(url: URL, credentials: Credentials? = nil) {
		self.init(url: url, credentials: credentials, urlSession: .shared)
	}

	public convenience init(host: String, port: Int = 9091, path: String = "/transmission/rpc", credentials: Credentials? = nil) throws {
		var components = URLComponents()
		components.scheme = "http"
		components.host = host
		components.port = port
		components.path = path

		guard let url = components.url else {
			throw TransmissionClientError.invalidURL
		}

		self.init(url: url, credentials: credentials)
	}

	public func send<T: Method>(method: T) async throws -> T.Response {
		try await send(method: method, allowSessionIdRefresh: true)
	}

	private func send<T: Method>(method: T, allowSessionIdRefresh: Bool) async throws -> T.Response {
		let urlRequest = try createURLRequest(url, httpMethod: "POST", payload: Request(method: method))
		let (data, urlResponse) = try await urlSession.data(for: urlRequest)

		guard let httpResponse = urlResponse as? HTTPURLResponse else {
			throw TransmissionClientError.nonHTTPResponse
		}

		switch httpResponse.statusCode {
		case 200 ..< 300:
			let response = try jsonDecoder.decode(Response<T.Response>.self, from: data)
			switch response {
			case .success(let object): return object
			case .failure(let message): throw TransmissionClientError.failureResponse(message)
			}
		case 409 where allowSessionIdRefresh:
			refreshSessionId(from: httpResponse)
			return try await send(method: method, allowSessionIdRefresh: false)
		default:
			throw TransmissionClientError.httpError(statusCode: httpResponse.statusCode)
		}
	}

	private func createURLRequest<T: Encodable>(_ url: URL, httpMethod: String, payload: T) throws -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = httpMethod
		request.httpBody = try jsonEncoder.encode(payload)

		if let sessionId {
			request.setValue(sessionId, forHTTPHeaderField: HeaderName.sessionId)
		}

		if let credentials {
			let string = [credentials.username, credentials.password].joined(separator: ":")
			let base64 = Data(string.utf8).base64EncodedString()
			request.setValue("Basic \(base64)", forHTTPHeaderField: HeaderName.authorization)
		}

		return request
	}

	private func refreshSessionId(from response: HTTPURLResponse) {
		sessionId = response.value(forHTTPHeaderField: HeaderName.sessionId)
	}
}

public enum TransmissionClientError: LocalizedError {
	case invalidURL
	case nonHTTPResponse
	case failureResponse(String)
	case httpError(statusCode: Int)

	public var errorDescription: String? {
		switch self {
		case .invalidURL: return "Unable to create a valid URL from the provided components."
		case .nonHTTPResponse: return "Received a non-HTTP response from the server."
		case .failureResponse(let message): return message
		case .httpError(statusCode: let code): return "The server responded with an HTTP \(code) status."
		}
	}
}
