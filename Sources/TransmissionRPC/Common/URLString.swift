import Foundation

@propertyWrapper
public struct URLString {
	public let wrappedValue: String

	/// The URL this string represents. Throws an error if the string is not a valid URL.
	public var url: URL {
		get throws {
			guard let url = URL(string: wrappedValue) else {
				throw TransmissionError.invalidURL(wrappedValue)
			}
			return url
		}
	}

	public init(wrappedValue: String) {
		self.wrappedValue = wrappedValue
	}
}
