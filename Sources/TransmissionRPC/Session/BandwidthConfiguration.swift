public struct BandwidthConfiguration: Decodable {
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

	/// Speed limits to use when alternative limits are not active.
	public let standardLimits: BandwidthLimits

	/// Alternative speed limits.
	public let alternativeLimits: BandwidthLimits

	/// Indicates whether upload speed limit is enabled.
	public let uploadLimitEnabled: Bool

	/// Indicates whether download speed limit is enabled.
	public let downloadLimitEnabled: Bool

	/// Indicates whether alternative speed limits are currently overriding the standard limits.
	public let alternativeLimitsEnabled: Bool

	/// Schedule when alternative speed limits are active.
	public let alternativeLimitsSchedule: BandwidthLimitSchedule

	/// Indicates whether the alternative speed limit schedule is enabled.
	public let alternativeLimitsScheduleEnabled: Bool

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		standardLimits = BandwidthLimits(
			up: try container.decode(Int.self, forKey: .uploadLimit),
			down: try container.decode(Int.self, forKey: .downloadLimit)
		)

		alternativeLimits = BandwidthLimits(
			up: try container.decode(Int.self, forKey: .alternativeDownloadLimit),
			down: try container.decode(Int.self, forKey: .alternativeUploadLimit)
		)

		uploadLimitEnabled = try container.decode(Bool.self, forKey: .uploadLimitEnabled)
		downloadLimitEnabled = try container.decode(Bool.self, forKey: .downloadLimitEnabled)
		alternativeLimitsEnabled = try container.decode(Bool.self, forKey: .alternativeLimitsEnabled)

		alternativeLimitsSchedule = BandwidthLimitSchedule(
			days: BandwidthLimitSchedule.Weekday(rawValue: try container.decode(Int.self, forKey: .alternativeLimitsScheduleDays)),
			startTime: try container.decode(Int.self, forKey: .alternativeLimitsScheduleStartTime),
			endTime: try container.decode(Int.self, forKey: .alternativeLimitsScheduleEndTime)
		)

		alternativeLimitsScheduleEnabled = try container.decode(Bool.self, forKey: .alternativeLimitsScheduleEnabled)
	}
}

public struct BandwidthLimits {
	/// Upload speed limit in kilobytes per second.
	public let up: Int

	/// Download speed limit in kilobytes per second.
	public let down: Int
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
