import Foundation

public enum TransmissionError: LocalizedError, Equatable {
	case invalidURLComponents
	case invalidURL(String)
	case nonHTTPResponse
	case failureResponse(String)
	case httpError(statusCode: Int)
	case notImplemented(version: String, requiredVersion: String)
	case unsupportedApiVersion(version: Int)
	case invalidSemanticVersion(String)

	public var errorDescription: String? {
		switch self {
		case .invalidURLComponents:
			return "Unable to create a valid URL from the provided components."
		case .invalidURL(let string):
			return "Invalid URL: \(string)"
		case .nonHTTPResponse:
			return "Received a non-HTTP response from the server."
		case .failureResponse(let message):
			return message
		case .httpError(statusCode: let code):
			return "The server responded with an HTTP \(code) status."
		case let .notImplemented(version: version, requiredVersion: requiredVersion):
			return "Feature not implemented in RPC protocol version \(version), version \(requiredVersion) required"
		case .unsupportedApiVersion(version: let version):
			return "API versions starting from 5.2.0 (RPC version 16, Transmision version 3.0.0) are supported. Attempted to use RPC version \(version)."
		case .invalidSemanticVersion(let string):
			return "Invalid semantic version string '\(string)'"
		}
	}
}
