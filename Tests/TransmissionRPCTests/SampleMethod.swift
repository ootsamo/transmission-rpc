@testable import TransmissionRPC

struct SampleMethod: Method, Encodable {
	typealias Response = SampleResponse

	static let name = "sample"
}

struct SampleResponse: Decodable {
	let argument: Int
}
