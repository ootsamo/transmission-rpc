import Foundation

public enum TransmissionError: LocalizedError {
	case invalidURL
	case nonHTTPResponse
	case failureResponse(String)
	case httpError(statusCode: Int)

	public var errorDescription: String? {
		switch self {
		case .invalidURL: return "Unable to create a valid URL from the provided components."
		case .nonHTTPResponse: return "Received a non-HTTP response from the server."
		case .failureResponse(let message): return message
		case .httpError(statusCode: let code): return "The server responded with an HTTP \(code) status."
		}
	}
}
