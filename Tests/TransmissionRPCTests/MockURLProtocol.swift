import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class MockURLProtocol: URLProtocol {
	typealias Handler = (URLRequest) async throws -> (URLResponse, Data)
	static var handlers = [Handler]()

	override class func canInit(with request: URLRequest) -> Bool {
		true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override func startLoading() {
		guard !Self.handlers.isEmpty else {
			fatalError("No request handler set up")
		}

		let handler = Self.handlers.removeFirst()

		Task {
			do {
				let (response, data) = try await handler(request)
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
				client?.urlProtocol(self, didLoad: data)
				client?.urlProtocolDidFinishLoading(self)
			} catch {
				client?.urlProtocol(self, didFailWithError: error)
			}
		}
	}

	override func stopLoading() {}
}
