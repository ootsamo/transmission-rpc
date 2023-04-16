public struct FileHandlingConfiguration: Decodable {
	enum CodingKeys: String, CodingKey {
		case maximumCacheSize = "cache-size-mb"
		case configurationDirectoryPath = "config-dir"
		case renamePartialFiles = "rename-partial-files"
		case incompleteDirectoryPath = "incomplete-dir"
		case incompleteDirectoryEnabled = "incomplete-dir-enabled"
		case downloadDirectoryPath = "download-dir"
		case trashOriginalMetainfoFile = "trash-original-torrent-files"
	}

	/// Maximum size of disk cache in megabytes.
	public let maximumCacheSize: Int

	/// Path to Transmission's configuration directory.
	public let configurationDirectoryPath: String

	/// If true, filenames have a `.part` extension until they have been fully downloaded.
	public let renamePartialFiles: Bool

	/// Path to the directory where incomplete transfers are stored.
	public let incompleteDirectoryPath: String

	/// If true, incomplete transfers are stored in the directory specified in `incompleteDirectoryPath` until they are done.
	/// If false, files are downloaded directly to the directory specified in `downloadDirectoryPath`.
	public let incompleteDirectoryEnabled: Bool

	/// Path to the default download directory.
	public let downloadDirectoryPath: String

	/// Indicates whether the original metainfo file is deleted after a transfer is added.
	public let trashOriginalMetainfoFile: Bool
}
