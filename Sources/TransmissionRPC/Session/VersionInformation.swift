public struct VersionInformation: Decodable {
	enum CodingKeys: String, CodingKey {
		case apiVersion = "rpc-version"
		case semanticApiVersion = "rpc-version-semver"
		case minimumApiVersion = "rpc-version-minimum"
		case version = "version"
	}

	/// The current API semantic version.
	public var semanticApiVersion: SemanticVersion { get throws { try _optionalSemanticApiVersion.unwrappedValue }}
	@ApiVersionRequirement var optionalSemanticApiVersion: SemanticVersion?

	/// The current API version.
	public let apiVersion: Int

	/// The minimum API version supported by this server.
	public let minimumApiVersion: Int

	/// Transmission version and build information.
	public let version: String

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		apiVersion = try container.decode(forKey: .apiVersion)
		_optionalSemanticApiVersion = try ApiVersionRequirement(current: apiVersion, required: 17) {
			try container.decode(forKey: .semanticApiVersion)
		}
		minimumApiVersion = try container.decode(forKey: .minimumApiVersion)
		version = try container.decode(forKey: .version)
	}
}
