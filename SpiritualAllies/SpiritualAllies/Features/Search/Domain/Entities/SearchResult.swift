import Foundation

struct SpiritualSearchResponse: Equatable {
    let prompt: String
    let results: [SpiritualSearchResult]
    let suggestions: [String]
    let totalScanned: Int
}

struct SpiritualSearchResult: Equatable, Identifiable {
    let kind: String
    let id: String
    let title: String
    let subtitle: String
    let summary: String
    let score: Double?
    let priceFrom: Double?
    let currency: String?
    let thumbnailPath: String?
    let imageAlt: String?
    let why: String
    let pros: [String]
    let routeSection: String?
    let routeID: String?

    var stableID: String { "\(kind)-\(id)" }
}
