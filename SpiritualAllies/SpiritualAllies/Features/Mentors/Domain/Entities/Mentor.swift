import Foundation

struct MentorSection: Equatable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let heroImagePath: String?
    let totalCount: Int?
    let categories: [String]
    let page: MentorPage
}

struct MentorPage: Equatable {
    let items: [Mentor]
    let pageNumber: Int
    let totalElements: Int?
    let isLast: Bool
}

struct Mentor: Hashable, Identifiable {
    let id: String
    let name: String
    let location: String
    let lineage: String
    let experience: String
    let languages: String
    let category: String
    let tags: [String]
    let feeLabel: String?
    let rating: Double?
    let reviewCount: Int?
    let imagePath: String?
    let verified: Bool
}

struct MentorDetail: Equatable {
    let id: String
    let name: String
    let imagePath: String?
    let verified: Bool
    let featured: Bool
    let headline: String
    let lineage: String
    let rating: Double?
    let reviewCount: Int?
    let experience: String
    let students: String
    let since: String
    let languages: String
    let location: String
    let about: String
    let teachingFocus: [String]
    let catalogLive: String
    let posts: String
    let trust: String
    let followers: String
    let retreatsCount: String
    let feeLabel: String?
}
