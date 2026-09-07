import Foundation

protocol FetchMentorsUseCase: Sendable {
    func execute(page: Int, size: Int) async throws -> MentorSection
}

struct DefaultFetchMentorsUseCase: FetchMentorsUseCase {
    private let repository: MentorRepository

    init(repository: MentorRepository) { self.repository = repository }

    func execute(page: Int, size: Int) async throws -> MentorSection {
        try await repository.fetchMentors(page: page, size: size)
    }
}
