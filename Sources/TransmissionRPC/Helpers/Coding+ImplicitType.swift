import Foundation

extension KeyedDecodingContainer {
	public func decode<T: Decodable>(forKey key: Key) throws -> T {
		try decode(T.self, forKey: key)
	}

	public func decodeIfPresent<T: Decodable>(forKey key: Key) throws -> T? {
		try decodeIfPresent(T.self, forKey: key)
	}

	public func decode<T: DecodableWithConfiguration>(forKey key: Key, configuration: T.DecodingConfiguration) throws -> T {
		try decode(T.self, forKey: key, configuration: configuration)
	}
}

extension SingleValueDecodingContainer {
	func decode<T: Decodable>(_ type: T.Type) throws -> T {
		try decode(T.self)
	}
}
