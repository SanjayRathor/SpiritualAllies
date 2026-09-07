import Foundation

protocol MentorRepository: Sendable {
    func fetchMentors(page: Int, size: Int) async throws -> MentorSection
}
