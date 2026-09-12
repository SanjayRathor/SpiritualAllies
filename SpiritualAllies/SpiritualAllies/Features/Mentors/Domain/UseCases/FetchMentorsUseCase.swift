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

protocol FetchMentorDetailUseCase: Sendable {
    func execute(id: String) async throws -> MentorDetail
}

struct DefaultFetchMentorDetailUseCase: FetchMentorDetailUseCase {
    private let repository: MentorRepository

    init(repository: MentorRepository) { self.repository = repository }

    func execute(id: String) async throws -> MentorDetail {
        try await repository.fetchMentorDetail(id: id)
    }
}

protocol FetchMentorPageUseCase: Sendable {
    func featured(page: Int, size: Int) async throws -> MentorPage
    func browse(query: String, category: String?, page: Int, size: Int) async throws -> MentorPage
}

struct DefaultFetchMentorPageUseCase: FetchMentorPageUseCase {
    private let repository: MentorRepository

    init(repository: MentorRepository) { self.repository = repository }

    func featured(page: Int, size: Int) async throws -> MentorPage {
        try await repository.fetchFeatured(page: page, size: size)
    }

    func browse(query: String, category: String?, page: Int, size: Int) async throws -> MentorPage {
        try await repository.browseMentors(query: query, category: category, page: page, size: size)
    }
}
