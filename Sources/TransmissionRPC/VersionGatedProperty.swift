enum VersionGatedProperty<T> {
	case value(T)
	case notImplemented(currentVersion: Version?, requiredVersion: Version)

	typealias Version = Int

	var unwrapped: T {
		get throws {
			switch self {
			case .value(let value):
				return value
			case let .notImplemented(currentVersion: currentVersion, requiredVersion: requiredVersion):
				throw TransmissionError.notImplemented(version: currentVersion.map { "\($0)" } ?? "<unknown>", requiredVersion: "\(requiredVersion)")
			}
		}
	}

	init(current currentVersion: Version?, required requiredVersion: Version, value: () throws -> T) rethrows {
		if let currentVersion, currentVersion < requiredVersion {
			self = .notImplemented(currentVersion: currentVersion, requiredVersion: requiredVersion)
		} else {
			self = .value(try value())
		}
	}
}
