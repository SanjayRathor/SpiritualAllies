import Foundation

struct SearchResponseDTO: Decodable {
    let ok: Bool?
    let data: SearchDataDTO
}

struct SearchDataDTO: Decodable {
    let prompt: String?
    let results: [SearchResultDTO]?
    let suggestions: [String]?
    let totalScanned: Int?
}

struct SearchResultDTO: Decodable {
    let kind: String?
    let id: String?
    let title: String?
    let subtitle: String?
    let score: Double?
    let summary: String?
    let priceFrom: Double?
    let currency: String?
    let media: SearchMediaDTO?
    let why: String?
    let pros: [String]?
    let route: SearchRouteDTO?
}

struct SearchMediaDTO: Decodable {
    let thumbnailUrl: String?
    let alt: String?
}

struct SearchRouteDTO: Decodable {
    let section: String?
    let id: String?
}

struct SearchRequestDTO: Encodable {
    let prompt: String
    let topK: Int
    let filters: SearchFiltersDTO
}

struct SearchFiltersDTO: Encodable {
    let kinds: [String]
    let city: String
}
