import Foundation

public struct PieceStatus: Collection, DecodableWithConfiguration {
	public typealias Element = Bool
	public typealias Index = Int

	private let data: Data

	public let startIndex: Int = 0
	public let endIndex: Int

	public init(from decoder: Decoder, configuration pieceCount: Int) throws {
		let container = try decoder.singleValueContainer()
		let string = try container.decode(String.self)
		guard let data = Data(base64Encoded: Data(string.utf8)) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Can't decode base64 string '\(string)'")
		}
		self.data = data
		self.endIndex = pieceCount
	}

	public func index(after i: Int) -> Int { i + 1 }

	public subscript(position: Int) -> Bool {
		(data[position / 8] & (1 << (position % 8))) != 0
	}
}
