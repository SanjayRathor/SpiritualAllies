//
//  APIPlacesRemoteDataSource.swift
//  SpiritualAllies
//
//  Network-backed places data source with paging.
//

import Foundation

final class APIPlacesRemoteDataSource: PlacesRemoteDataSource {
    private let client: APIClient
    private let path: String

    init(client: APIClient, path: String = "sacred-places/public") {
        self.client = client
        self.path = path
    }

    func fetchPlaces(page: Int, size: Int) async throws -> SacredPlacesPageDTO {
        let endpoint = Endpoint(
            path: path,
            method: .get,
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        )
        return try await client.request(endpoint, as: SacredPlacesPageDTO.self)
    }
}
