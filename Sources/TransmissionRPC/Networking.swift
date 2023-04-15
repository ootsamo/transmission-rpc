protocol Networking {
	func send<T: Method>(method: T) async throws -> T.Response
}
