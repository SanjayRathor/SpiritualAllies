import Foundation

final class SearchRepositoryImpl: SearchRepository {
    private let remoteDataSource: SearchRemoteDataSource

    init(remoteDataSource: SearchRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func search(prompt: String, topK: Int, city: String) async throws -> SpiritualSearchResponse {
        let response = try await remoteDataSource.search(prompt: prompt, topK: topK, city: city)
        return SpiritualSearchResponse(
            prompt: response.data.prompt ?? prompt,
            results: (response.data.results ?? []).compactMap { item in
                guard let id = item.id, let title = item.title else { return nil }
                return SpiritualSearchResult(
                    kind: item.kind ?? "RESULT",
                    id: id,
                    title: title,
                    subtitle: item.subtitle ?? "",
                    summary: item.summary ?? "",
                    score: item.score,
                    priceFrom: item.priceFrom,
                    currency: item.currency,
                    thumbnailPath: item.media?.thumbnailUrl,
                    imageAlt: item.media?.alt,
                    why: item.why ?? "",
                    pros: item.pros ?? [],
                    routeSection: item.route?.section,
                    routeID: item.route?.id
                )
            },
            suggestions: response.data.suggestions ?? [],
            totalScanned: response.data.totalScanned ?? 0
        )
    }
}
