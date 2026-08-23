//
//  APIError.swift
//  SpiritualAllies
//
//  Domain-agnostic networking error surfaced by the APIClient.
//

import Foundation

/// Errors that the networking layer can produce. Concrete transport errors
/// (Alamofire, URLSession, ...) are mapped into these cases so higher layers
/// never depend on a specific networking library.
enum APIError: Error, Equatable {
    case invalidURL
    case transport(message: String)
    case server(statusCode: Int)
    case decoding(message: String)
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .transport(let message):
            return "Network error: \(message)"
        case .server(let statusCode):
            return "Server returned status code \(statusCode)."
        case .decoding(let message):
            return "Failed to decode response: \(message)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
