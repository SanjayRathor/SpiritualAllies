//
//  APIHomeRemoteDataSource.swift
//  SpiritualAllies
//
//  Real network-backed data source. Wired against the APIClient abstraction so
//  It loads the public landing screen configuration.
//

import Foundation

final class APIHomeRemoteDataSource: HomeRemoteDataSource {
    private let client: APIClient
    private let path: String

    init(client: APIClient, path: String = "mobile/v1/dashboard") {
        self.client = client
        self.path = path
    }

    func fetchDashboard() async throws -> HomeResponseDTO {
        let endpoint = Endpoint(path: path, method: .get)
        return try await client.request(endpoint, as: HomeResponseDTO.self)
    }
}
