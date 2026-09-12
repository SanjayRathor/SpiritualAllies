import Foundation

protocol MentorRepository: Sendable {
    func fetchMentors(page: Int, size: Int) async throws -> MentorSection
    func fetchFeatured(page: Int, size: Int) async throws -> MentorPage
    func browseMentors(query: String, category: String?, page: Int, size: Int) async throws -> MentorPage
    func fetchMentorDetail(id: String) async throws -> MentorDetail
}
