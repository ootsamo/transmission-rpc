import Foundation

public struct BandwidthConfiguration: DecodableWithConfiguration {
	enum CodingKeys: String, CodingKey {
		case uploadLimit = "speed-limit-up"
		case downloadLimit = "speed-limit-down"
		case downloadLimitEnabled = "speed-limit-down-enabled"
		case uploadLimitEnabled = "speed-limit-up-enabled"
		case alternativeUploadLimit = "alt-speed-up"
		case alternativeDownloadLimit = "alt-speed-down"
		case alternativeLimitsEnabled = "alt-speed-enabled"
		case alternativeLimitsScheduleStartTime = "alt-speed-time-begin"
		case alternativeLimitsScheduleEndTime = "alt-speed-time-end"
		case alternativeLimitsScheduleDays = "alt-speed-time-day"
		case alternativeLimitsScheduleEnabled = "alt-speed-time-enabled"
	}

	/// The transfer rate limits to use when alternative limits are not enabled.
	public let standardLimits: TransferRates

	/// The transfer rate limits to use when alternative limits are enabled.
	public let alternativeLimits: TransferRates

	/// A boolean value indicating whether the standard upload rate limit is enabled.
	public let uploadLimitEnabled: Bool

	/// A boolean value indicating whether the standard download rate limit is enabled.
	public let downloadLimitEnabled: Bool

	/// A boolean value indicating whether alternative transfer rate limits are currently overriding the standard limits.
	public let alternativeLimitsEnabled: Bool

	/// A schedule that describes when alternative transfer rate limits should be enabled.
	public let alternativeLimitsSchedule: BandwidthLimitSchedule

	/// A boolean value indicating whether the alternative transfer rate limit schedule is enabled.
	public let alternativeLimitsScheduleEnabled: Bool

	public init(from decoder: Decoder, configuration units: SessionUnits) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let kiloMultiplier = units.speed.kiloMultiplier

		standardLimits = TransferRates(
			up: try container.decode(forKey: .uploadLimit) * kiloMultiplier,
			down: try container.decode(forKey: .downloadLimit) * kiloMultiplier
		)

		alternativeLimits = TransferRates(
			up: try container.decode(forKey: .alternativeDownloadLimit) * kiloMultiplier,
			down: try container.decode(forKey: .alternativeUploadLimit) * kiloMultiplier
		)

		uploadLimitEnabled = try container.decode(forKey: .uploadLimitEnabled)
		downloadLimitEnabled = try container.decode(forKey: .downloadLimitEnabled)
		alternativeLimitsEnabled = try container.decode(forKey: .alternativeLimitsEnabled)

		alternativeLimitsSchedule = BandwidthLimitSchedule(
			days: BandwidthLimitSchedule.Weekday(rawValue: try container.decode(forKey: .alternativeLimitsScheduleDays)),
			startTime: try container.decode(forKey: .alternativeLimitsScheduleStartTime),
			endTime: try container.decode(forKey: .alternativeLimitsScheduleEndTime)
		)

		alternativeLimitsScheduleEnabled = try container.decode(forKey: .alternativeLimitsScheduleEnabled)
	}
}

public struct BandwidthLimitSchedule {
	public struct Weekday: OptionSet {
		public let rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}

		public static let sunday = Self(rawValue: 1)
		public static let monday = Self(rawValue: 1 << 1)
		public static let tuesday = Self(rawValue: 1 << 2)
		public static let wednesday = Self(rawValue: 1 << 3)
		public static let thursday = Self(rawValue: 1 << 4)
		public static let friday = Self(rawValue: 1 << 5)
		public static let saturday = Self(rawValue: 1 << 6)
		public static let weekdays: Self = [.monday, .tuesday, .wednesday, .thursday, .friday]
		public static let weekend: Self = [.saturday, .sunday]
		public static let all: Self = [.weekdays, .weekend]
	}

	/// Days of the week the schedule applies to.
	public let days: Weekday

	/// Start time of the schedule, in minutes since midnight.
	public let startTime: Int

	/// End time of the schedule, in minutes since midnight.
	public let endTime: Int
}
