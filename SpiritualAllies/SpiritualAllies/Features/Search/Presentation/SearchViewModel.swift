import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(SpiritualSearchResponse)
        case failed(String)
    }

    var query: String
    private(set) var state: State = .idle
    private let searchContent: SearchSpiritualContentUseCase

    init(initialQuery: String, searchContent: SearchSpiritualContentUseCase) {
        query = initialQuery
        self.searchContent = searchContent
    }

    func onAppear() async {
        guard case .idle = state else { return }
        await search()
    }

    func search() async {
        let prompt = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        guard ToastHelper.requireNetwork() else {
            state = .failed(AppStrings.Error.noInternet)
            return
        }

        state = .loading
        do {
            state = .loaded(try await searchContent.execute(prompt: prompt, topK: 8, city: ""))
        } catch {
            state = .failed((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
