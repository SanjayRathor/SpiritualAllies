import Foundation

protocol SearchRemoteDataSource: Sendable {
    func search(prompt: String, topK: Int, city: String) async throws -> SearchResponseDTO
}

final class APISearchRemoteDataSource: SearchRemoteDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func search(prompt: String, topK: Int, city: String) async throws -> SearchResponseDTO {
        let request = SearchRequestDTO(
            prompt: prompt,
            topK: topK,
            filters: SearchFiltersDTO(
                kinds: ["OFFERING", "SACRED_PLACE", "MENTOR", "PACKAGE"],
                city: city
            )
        )
        let endpoint = Endpoint(
            path: "mobile/v1/search",
            method: .post,
            headers: ["Content-Type": "application/json", "Accept": "application/json"],
            body: try JSONEncoder().encode(request)
        )
        return try await client.request(endpoint, as: SearchResponseDTO.self)
    }
}
