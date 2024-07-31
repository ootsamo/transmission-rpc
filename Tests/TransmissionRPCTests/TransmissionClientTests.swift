import Testing
import Foundation
import TransmissionRPC

struct TransmissionClientTests {
	@Test("Initialization succeeds")
	func initialization() throws {
		_ = try TransmissionClient(host: "example.com", path: "/dev/null")
	}

	@Test("Initialization fails with an invalid URL")
	func invalidURL() {
		#expect(throws: TransmissionError.invalidURLComponents) {
			try TransmissionClient(host: "example.com", path: "dev/null")
		}
	}
}
