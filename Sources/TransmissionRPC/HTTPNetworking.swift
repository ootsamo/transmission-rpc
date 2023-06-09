import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HTTPNetworking: Networking {
	enum HeaderName {
		static let sessionId = "X-Transmission-Session-Id"
		static let authorization = "Authorization"
	}

	private let url: URL
	private let credentials: Credentials?
	private let urlSession: URLSession
	private let jsonEncoder = JSONEncoder()
	private let jsonDecoder = JSONDecoder()

	private var sessionId: String?

	var apiVersion: Int? {
		get { jsonDecoder.userInfo[.apiVersion] as? Int }
		set { jsonDecoder.userInfo[.apiVersion] = newValue }
	}

	init(url: URL, credentials: Credentials?, urlSession: URLSession = .shared) {
		self.url = url
		self.credentials = credentials
		self.urlSession = urlSession
	}

	func send<T: Method>(method: T) async throws -> T.Response {
		try await send(method: method, allowSessionIdRefresh: true)
	}

	private func send<T: Method>(method: T, allowSessionIdRefresh: Bool) async throws -> T.Response {
		let urlRequest = try createURLRequest(url, httpMethod: "POST", payload: Request(method: method))
		let (data, urlResponse) = try await urlSession.data(for: urlRequest)

		guard let httpResponse = urlResponse as? HTTPURLResponse else {
			throw TransmissionError.nonHTTPResponse
		}

		switch httpResponse.statusCode {
		case 200 ..< 300:
			let response = try jsonDecoder.decode(Response<T.Response>.self, from: data)
			switch response {
			case .success(let object): return object
			case .failure(let message): throw TransmissionError.failureResponse(message)
			}
		case 409 where allowSessionIdRefresh:
			refreshSessionId(from: httpResponse)
			return try await send(method: method, allowSessionIdRefresh: false)
		default:
			throw TransmissionError.httpError(statusCode: httpResponse.statusCode)
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

extension CodingUserInfoKey {
	static let apiVersion = {
		guard let key = Self(rawValue: "apiVersion") else {
			fatalError("Unable to create apiVersion CodingUserInfoKey")
		}
		return key
	}()
}
