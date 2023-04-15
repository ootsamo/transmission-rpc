public protocol TransmissionClient {
	func send<T: Method>(method: T) async throws -> T.Response
}
