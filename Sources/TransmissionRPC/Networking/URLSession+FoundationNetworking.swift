#if canImport(FoundationNetworking)

import Foundation
import FoundationNetworking

extension URLSession {
	func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
		try await withCheckedThrowingContinuation { continuation in
			dataTask(with: request) { data, response, error in
				if let error {
					continuation.resume(throwing: error)
				} else {
					guard let data, let response else {
						fatalError("Data or response were unexpectedly nil after a successful request")
					}
					continuation.resume(returning: (data, response))
				}
			}.resume()
		}
	}
}

#endif
