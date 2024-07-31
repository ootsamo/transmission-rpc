import Foundation

public struct Tracker: Decodable {
	enum CodingKeys: String, CodingKey {
		case id
		case tier
		case sitename = "sitename"
		case announceURL = "announce"
		case scrapeURL = "scrape"
	}

	/// A local identifier for the tracker.
	public let id: Int

	/// The tier the tracker belongs to.
	public let tier: Int

	/// The site name of the tracker.
	@VersionRequirement(17)
	public var sitename: String

	/// The URL to use for announce requests.
	public let announceURL: URL

	/// The URL to use for scrape requests.
	public let scrapeURL: URL

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let apiVersion = decoder.userInfo[.apiVersion] as? Int
		id = try container.decode(forKey: .id)
		tier = try container.decode(forKey: .tier)
		_sitename = try Self.sitename(apiVersion: apiVersion) {
			try container.decode(forKey: .sitename)
		}
		announceURL = try container.decode(forKey: .announceURL)
		scrapeURL = try container.decode(forKey: .scrapeURL)
	}
}
