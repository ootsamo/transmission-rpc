import XCTest
@testable import TransmissionRPC

final class TransmissionClientTests: XCTestCase {
	func testClientInitialization() {
		XCTAssertNoThrow(try TransmissionClient(host: "example.com", path: "/dev/null"))

		XCTAssertThrowsError(try TransmissionClient(host: "example.com", path: "dev/null")) {
			guard case .invalidURLComponents = $0 as? TransmissionError else {
				XCTFail("Incorrect error thrown: \($0)")
				return
			}
		}
	}
}
