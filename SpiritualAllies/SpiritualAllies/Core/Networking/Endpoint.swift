//
//  Endpoint.swift
//  SpiritualAllies
//
//  A transport-agnostic description of a single HTTP request.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Value type describing an HTTP request independently of the networking
/// library used to execute it. Data sources build `Endpoint`s and hand them
/// to the `APIClient`.
struct Endpoint {
    /// Path relative to the environment's `apiBaseURL`, e.g. "home/dashboard".
    let path: String
    let method: HTTPMethod
    /// URL query items appended to the request.
    let queryItems: [URLQueryItem]
    /// Additional/override HTTP headers.
    let headers: [String: String]
    /// Optional JSON body encoded as `Data`.
    let body: Data?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    /// Resolves the fully-qualified URL against the given base URL.
    func url(relativeTo baseURL: URL) -> URL? {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else { return nil }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }
}
