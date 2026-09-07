import Foundation

final class MentorRepositoryImpl: MentorRepository {
    private let remoteDataSource: MentorRemoteDataSource

    init(remoteDataSource: MentorRemoteDataSource) { self.remoteDataSource = remoteDataSource }

    func fetchMentors(page: Int, size: Int) async throws -> MentorSection {
        let section = MentorDTOMapper.map(try await remoteDataSource.fetchMentors(page: page, size: size))
#if DEBUG
        print("[Mentors] decoded items=\(section.page.items.count), total=\(section.totalCount ?? 0)")
#endif
        return section
    }
}
