import Testing
import Foundation
@testable import TransmissionRPC

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@Suite(.serialized)
final class HTTPNetworkingTests {
	private let url: URL
	private let networking: HTTPNetworking

	init() throws {
		url = try #require(URL(string: "http://example.com"))

		let configuration = URLSessionConfiguration.default
		configuration.protocolClasses = [MockURLProtocol.self]
		let urlSession = URLSession(configuration: configuration)
		networking = HTTPNetworking(url: url, credentials: nil, urlSession: urlSession)
	}

	@Test("Success response is handled correctly")
	func successResponse() async throws {
		let data = Data(#"{"result": "success", "arguments": {"argument": 3}}"#.utf8)
		let httpResponse = try createResponse()

		MockURLProtocol.handlers = [{ _ in (httpResponse, data) }]
		let response = try await networking.send(method: SampleMethod())

		assert(response.argument == 3)
	}

	@Test("Failure response is handled correctly")
	func failureResponse() async throws {
		let errorMessage = "Something went wrong"
		let data = Data(#"{"result": "\#(errorMessage)", "arguments": []}"#.utf8)
		let httpResponse = try createResponse()

		MockURLProtocol.handlers = [{ _ in (httpResponse, data) }]

		await #expect {
			try await networking.send(method: SampleMethod())
		} throws: { error in
			guard case .failureResponse(let message) = error as? TransmissionError else {
				return false
			}
			return message == errorMessage
		}
	}

	private func createResponse(statusCode: Int = 200, headerFields: [String: String]? = nil) throws -> HTTPURLResponse {
		try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields))
	}

	deinit {
		MockURLProtocol.handlers.removeAll()
	}
}
