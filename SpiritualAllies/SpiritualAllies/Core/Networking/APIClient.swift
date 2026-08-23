//
//  APIClient.swift
//  SpiritualAllies
//
//  Abstraction over the HTTP transport. Higher layers depend on this
//  protocol (Dependency Inversion) — never on Alamofire directly.
//

import Foundation

protocol APIClient: Sendable {
    /// Executes `endpoint` and decodes the JSON response into `T`.
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}
