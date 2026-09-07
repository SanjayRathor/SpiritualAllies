import Foundation

protocol MentorRemoteDataSource: Sendable {
    func fetchMentors(page: Int, size: Int) async throws -> MentorResponseDTO
}

final class APIMentorRemoteDataSource: MentorRemoteDataSource {
    private let client: APIClient

    init(client: APIClient) { self.client = client }

    func fetchMentors(page: Int, size: Int) async throws -> MentorResponseDTO {
        let endpoint = Endpoint(
            path: "mobile/screen",
            queryItems: [
                URLQueryItem(name: "section", value: "mentors"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
        )
#if DEBUG
        if let url = endpoint.url(relativeTo: AppEnvironment.current.apiBaseURL) {
            print("[Mentors] GET \(url.absoluteString)")
        }
#endif
        return try await client.request(endpoint, as: MentorResponseDTO.self)
    }
}
