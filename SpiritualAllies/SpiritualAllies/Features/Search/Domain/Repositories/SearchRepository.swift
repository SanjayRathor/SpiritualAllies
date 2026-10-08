import Foundation

protocol SearchRepository: Sendable {
    func search(prompt: String, topK: Int, city: String) async throws -> SpiritualSearchResponse
}
