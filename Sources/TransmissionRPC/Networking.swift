protocol Networking: AnyObject {
	var apiVersion: Int? { get set }
	func send<T: Method>(method: T) async throws -> T.Response
}
