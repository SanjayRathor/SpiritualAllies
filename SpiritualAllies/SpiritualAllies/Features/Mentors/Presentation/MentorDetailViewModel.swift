import Foundation
import Observation

@MainActor
@Observable
final class MentorDetailViewModel {
    enum LoadState: Equatable { case idle, loading, loaded, failed(String) }

    private(set) var state: LoadState = .idle
    private(set) var detail: MentorDetail?
    private var hasLoaded = false
    private let mentorID: String
    private let fetchDetail: FetchMentorDetailUseCase

    init(mentorID: String, fetchDetail: FetchMentorDetailUseCase) {
        self.mentorID = mentorID
        self.fetchDetail = fetchDetail
    }

    func onAppear() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        state = .loading
        do {
            detail = try await fetchDetail.execute(id: mentorID)
            state = .loaded
        } catch {
            state = .failed((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
