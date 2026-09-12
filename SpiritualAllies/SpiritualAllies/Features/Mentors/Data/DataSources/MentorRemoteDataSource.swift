import Foundation

protocol MentorRemoteDataSource: Sendable {
    func fetchMentors(page: Int, size: Int) async throws -> MentorResponseDTO
    func fetchFeatured(page: Int, size: Int) async throws -> MentorPageResponseDTO
    func browseMentors(query: String, category: String?, page: Int, size: Int) async throws -> MentorPageResponseDTO
    func fetchMentorDetail(id: String) async throws -> MentorDetailResponseDTO
}

final class APIMentorRemoteDataSource: MentorRemoteDataSource {
    private let client: APIClient

    init(client: APIClient) { self.client = client }

    func fetchMentors(page: Int, size: Int) async throws -> MentorResponseDTO {
        let endpoint = screenEndpoint(page: page, size: size)
        log(endpoint)
        return try await client.request(endpoint, as: MentorResponseDTO.self)
    }

    func fetchFeatured(page: Int, size: Int) async throws -> MentorPageResponseDTO {
        let endpoint = guruEndpoint(path: "gurus/featured", page: page, size: size)
        log(endpoint)
        return try await client.request(endpoint, as: MentorPageResponseDTO.self)
    }

    func browseMentors(query: String, category: String?, page: Int, size: Int) async throws -> MentorPageResponseDTO {
        var endpoint = guruEndpoint(path: "gurus/browse", page: page, size: size)
        var queryItems = endpoint.queryItems
        if !query.isEmpty { queryItems.append(URLQueryItem(name: "search", value: query)) }
        if let category, !category.isEmpty { queryItems.append(URLQueryItem(name: "category", value: category)) }
        endpoint = Endpoint(path: endpoint.path, queryItems: queryItems)
        log(endpoint)
        return try await client.request(endpoint, as: MentorPageResponseDTO.self)
    }

    func fetchMentorDetail(id: String) async throws -> MentorDetailResponseDTO {
        let endpoint = Endpoint(path: "gurus/\(id)")
        log(endpoint)
        return try await client.request(endpoint, as: MentorDetailResponseDTO.self)
    }

    private func screenEndpoint(page: Int, size: Int) -> Endpoint {
        Endpoint(
            path: "mobile/screen",
            queryItems: [
                URLQueryItem(name: "section", value: "mentors"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        )
    }

    private func guruEndpoint(path: String, page: Int, size: Int) -> Endpoint {
        Endpoint(
            path: path,
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        )
    }

    private func log(_ endpoint: Endpoint) {
#if DEBUG
        if let url = endpoint.url(relativeTo: AppEnvironment.current.apiBaseURL) {
            print("[Mentors] GET \(url.absoluteString)")
        }
#endif
    }
}
