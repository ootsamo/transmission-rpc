import XCTest
@testable import TransmissionRPC

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class TransmissionHTTPClientTests: XCTestCase {
	private let url = {
		guard let url = URL(string: "http://example.com") else {
			fatalError("Unable to create URL")
		}
		return url
	}()

	private lazy var client = {
		let configuration = URLSessionConfiguration.default
		configuration.protocolClasses = [MockURLProtocol.self]
		let urlSession = URLSession(configuration: configuration)
		return TransmissionHTTPClient(url: url, credentials: nil, urlSession: urlSession)
	}()

	override class func tearDown() {
		MockURLProtocol.handlers.removeAll()
	}

	func testClientInitialization() {
		XCTAssertNoThrow(try TransmissionHTTPClient(host: "example.com", path: "/dev/null"))

		XCTAssertThrowsError(try TransmissionHTTPClient(host: "example.com", path: "dev/null")) {
			guard case .invalidURL = $0 as? TransmissionClientError else {
				XCTFail("Incorrect error thrown: \($0)")
				return
			}
		}
	}

	func testSuccessResponse() async throws {
		let data = Data(#"{"result": "success", "arguments": {"argument": 3}}"#.utf8)
		let httpResponse = createResponse()

		let handler: MockURLProtocol.Handler = { _ in (httpResponse, data) }
		MockURLProtocol.handlers.append(handler)

		let response = try await client.send(method: SampleMethod())
		XCTAssertEqual(response.argument, 3)
	}

	func testFailureResponse() async throws {
		let errorMessage = "Something went wrong"
		let data = Data(#"{"result": "\#(errorMessage)", "arguments": []}"#.utf8)
		let httpResponse = createResponse()

		let handler: MockURLProtocol.Handler = { _ in (httpResponse, data) }
		MockURLProtocol.handlers.append(handler)

		do {
			_ = try await client.send(method: SampleMethod())
			XCTFail("Call did not throw an error")
		} catch {
			guard case .failureResponse(let message) = error as? TransmissionClientError else {
				XCTFail("Incorrect error thrown: \(error)")
				return
			}
			XCTAssertEqual(message, errorMessage)
		}
	}

	private func createResponse(statusCode: Int = 200, headerFields: [String: String]? = nil) -> HTTPURLResponse {
		guard let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields) else {
			fatalError("Unable to create HTTP response")
		}
		return response
	}
}
