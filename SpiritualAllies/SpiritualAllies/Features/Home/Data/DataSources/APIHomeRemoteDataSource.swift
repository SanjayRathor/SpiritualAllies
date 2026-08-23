//
//  APIHomeRemoteDataSource.swift
//  SpiritualAllies
//
//  Real network-backed data source. Wired against the APIClient abstraction so
//  it is ready for the actual endpoint once the backend path is confirmed.
//

import Foundation

final class APIHomeRemoteDataSource: HomeRemoteDataSource {
    private let client: APIClient
    private let path: String

    init(client: APIClient, path: String = "admin/mobile/dashboard") {
        self.client = client
        self.path = path
    }

    func fetchDashboard() async throws -> HomeResponseDTO {
        let endpoint = Endpoint(path: path, method: .get)
        return try await client.request(endpoint, as: HomeResponseDTO.self)
    }
}
