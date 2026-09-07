//
//  OfferingRemoteDataSource.swift
//  SpiritualAllies
//

import Foundation

protocol OfferingRemoteDataSource: Sendable {
    func fetchOfferings(page: Int, size: Int) async throws -> OfferingResponseDTO
}

final class APIOfferingRemoteDataSource: OfferingRemoteDataSource {
    private let client: APIClient
    private let path: String

    init(client: APIClient, path: String = "mobile/screen") {
        self.client = client
        self.path = path
    }

    func fetchOfferings(page: Int, size: Int) async throws -> OfferingResponseDTO {
        let endpoint = Endpoint(
            path: path,
            queryItems: [
                URLQueryItem(name: "section", value: "offerings"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        )

#if DEBUG
        if let url = endpoint.url(relativeTo: AppEnvironment.current.apiBaseURL) {
            print("[Offering] GET \(url.absoluteString)")
        }
#endif

        return try await client.request(endpoint, as: OfferingResponseDTO.self)
    }
}
