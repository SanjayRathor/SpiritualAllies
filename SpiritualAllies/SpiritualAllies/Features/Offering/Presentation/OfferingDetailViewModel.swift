import Foundation
import Observation

@MainActor
@Observable
final class OfferingDetailViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(OfferingDetail)
        case failed(String)
    }

    private(set) var state: State = .idle
    private let offeringID: String
    private let fetchDetail: FetchOfferingDetailUseCase

    init(offeringID: String, fetchDetail: FetchOfferingDetailUseCase) {
        self.offeringID = offeringID
        self.fetchDetail = fetchDetail
    }

    func onAppear() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        guard ToastHelper.requireNetwork() else {
            state = .failed(AppStrings.Error.noInternet)
            return
        }
        state = .loading
        do {
            state = .loaded(try await fetchDetail.execute(id: offeringID))
        } catch {
            state = .failed((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
