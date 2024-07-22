public struct SessionUnits: Decodable {
	enum CodingKeys: String, CodingKey {
		case speedKiloMultiplier = "speed-bytes"
		case sizeKiloMultiplier = "size-bytes"
		case memoryKiloMultiplier = "memory-bytes"
		case speedUnitSymbols = "speed-units"
		case sizeUnitSymbols = "size-units"
		case memoryUnitSymbols = "memory-units"
	}

	public let speed: SessionUnitCategory
	public let size: SessionUnitCategory
	public let memory: SessionUnitCategory

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		speed = try SessionUnitCategory(
			kiloMultiplier: container.decode(forKey: .speedKiloMultiplier),
			unitSymbols: container.decode(forKey: .speedUnitSymbols)
		)

		size = try SessionUnitCategory(
			kiloMultiplier: container.decode(forKey: .sizeKiloMultiplier),
			unitSymbols: container.decode(forKey: .sizeUnitSymbols)
		)

		memory = try SessionUnitCategory(
			kiloMultiplier: container.decode(forKey: .memoryKiloMultiplier),
			unitSymbols: container.decode(forKey: .memoryUnitSymbols)
		)
	}
}

public struct SessionUnitCategory {
	public let kiloMultiplier: Int
	public let unitSymbols: [String]
}
