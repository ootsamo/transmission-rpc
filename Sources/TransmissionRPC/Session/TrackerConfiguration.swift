import Foundation

public struct TrackerConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case defaultTrackers = "default-trackers"
	}

	public struct Tier {
		/// A list of trackers in this tier.
		public let trackers: [Tracker]
	}

	/// A list of trackers grouped by tier, where the first tier has the highest priority.
	public let tiers: [Tier]

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let string = try container.decode(String.self, forKey: .defaultTrackers)
		tiers = string
			.components(separatedBy: "\n\n")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { !$0.isEmpty }
			.map {
				Tier(trackers: $0.components(separatedBy: "\n").map(Tracker.init))
			}
	}
}

public struct Tracker {
	let urlString: String

	/// The announce URL for this tracker.
	public var url: URL {
		get throws {
			guard let url = URL(string: urlString) else {
				throw TransmissionError.invalidURL(urlString)
			}
			return url
		}
	}
}
