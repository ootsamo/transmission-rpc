public struct SemanticVersion: Comparable, LosslessStringConvertible, Decodable {
	let major: Int
	let minor: Int
	let patch: Int

	var string: String {
		[major, minor, patch]
			.map(String.init)
			.joined(separator: ".")
	}

	public var description: String { string }

	init(string: String) throws {
		let components = string.components(separatedBy: ".")
		guard 1 ... 3 ~= components.count else {
			throw TransmissionError.invalidSemanticVersion(string)
		}

		let parsed = try components.map {
			guard let int = Int($0) else {
				throw TransmissionError.invalidSemanticVersion(string)
			}
			return int
		}

		major = parsed[0]
		minor = parsed.indices.contains(1) ? parsed[1] : 0
		patch = parsed.indices.contains(2) ? parsed[2] : 0
	}

	public init?(_ description: String) {
		try? self.init(string: description)
	}

	init(_ major: Int, _ minor: Int, _ patch: Int) {
		self.major = major
		self.minor = minor
		self.patch = patch
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let string = try container.decode(String.self)
		try self.init(string: string)
	}

	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.string.compare(rhs.string, options: .numeric) == .orderedAscending
	}
}
