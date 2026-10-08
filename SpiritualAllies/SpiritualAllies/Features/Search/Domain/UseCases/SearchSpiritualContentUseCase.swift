import Foundation

protocol SearchSpiritualContentUseCase: Sendable {
    func execute(prompt: String, topK: Int, city: String) async throws -> SpiritualSearchResponse
}

struct DefaultSearchSpiritualContentUseCase: SearchSpiritualContentUseCase {
    let repository: SearchRepository

    func execute(prompt: String, topK: Int = 8, city: String = "") async throws -> SpiritualSearchResponse {
        try await repository.search(prompt: prompt, topK: topK, city: city)
    }
}
