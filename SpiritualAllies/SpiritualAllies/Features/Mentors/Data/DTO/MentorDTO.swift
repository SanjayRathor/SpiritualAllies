import Foundation

struct MentorResponseDTO: Decodable {
    let section: MentorSectionDTO

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        let directCatalog = try? container.decodeIfPresent(MentorCatalogDTO.self, forKey: .catalog)
        let nested = try? container.decodeIfPresent(MentorEnvelopeDTO.self, forKey: .data)
        let catalog = directCatalog ?? nested?.catalog
        let session = (try? container.decodeIfPresent(MentorSessionDTO.self, forKey: .session)) ?? nested?.session
        let page = catalog?.featured ?? catalog?.items ?? MentorPageDTO(content: [], page: 0, totalElements: nil, totalPages: nil, last: true)
        section = MentorSectionDTO(session: session, page: page)
    }
}

struct MentorPageResponseDTO: Decodable {
    let page: MentorPageDTO

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        let catalog = try? container.decodeIfPresent(MentorCatalogDTO.self, forKey: .catalog)
        if let featured = catalog?.featured {
            page = featured
        } else if let items = catalog?.items {
            page = items
        } else {
            page = MentorPageDTO(
                content: container.decodeArray(for: [.content, .items, .mentors, .results]) ?? [],
                page: container.decodeInt(for: [.page, .pageNumber, .number]),
                totalElements: container.decodeInt(for: [.totalElements, .total, .count]),
                totalPages: container.decodeInt(for: [.totalPages, .pages]),
                last: container.decodeBool(for: [.last, .isLast])
            )
        }
    }
}

struct MentorDetailResponseDTO: Decodable {
    let detail: MentorDetailPayloadDTO

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        detail = (try? container.decodeIfPresent(MentorDetailPayloadDTO.self, forKey: .data))
            ?? (try? container.decodeIfPresent(MentorDetailPayloadDTO.self, forKey: .guru))
            ?? MentorDetailPayloadDTO(container: container)
    }
}

struct MentorDetailPayloadDTO: Decodable {
    let id: String?
    let name: String?
    let imagePath: String?
    let verified: Bool
    let featured: Bool
    let headline: String?
    let lineage: String?
    let rating: Double?
    let reviewCount: Int?
    let experience: String?
    let students: String?
    let since: String?
    let languages: String?
    let location: String?
    let about: String?
    let teachingFocus: [String]
    let catalogLive: String?
    let posts: String?
    let trust: String?
    let followers: String?
    let retreatsCount: String?
    let fee: Double?
    let currency: String?

    init(container: KeyedDecodingContainer<MentorCodingKey>) {
        id = container.decodeString(for: [.id, .mentorId, .guruId, .uuid])
        name = container.decodeString(for: [.name, .fullName, .spiritualName, .mentorName, .displayName, .title])
        imagePath = container.decodeImagePath(for: [.image, .imageUrl, .profilePhotoUrl, .photoUrl, .thumbnailUrl, .gallery])
        verified = container.decodeBool(for: [.verified, .isVerified]) ?? false
        featured = container.decodeBool(for: [.featured, .isFeatured]) ?? false
        headline = container.decodeString(for: [.headline, .tagline, .specialization, .practice])
        lineage = container.decodeString(for: [.lineage, .spiritualLineage, .tradition])
        rating = container.decodeDouble(for: [.rating, .averageRating, .avgRating, .score])
        reviewCount = container.decodeInt(for: [.reviewCount, .reviews, .ratingsCount])
        experience = container.decodeString(for: [.experience, .yearsExperience, .years, .experienceYears])
        students = container.decodeString(for: [.students, .studentCount])
        since = container.decodeString(for: [.since, .memberSince, .joinedSince])
        languages = container.decodeString(for: [.languages, .language, .spokenLanguages])
        location = container.decodeString(for: [.location, .address, .city])
        about = container.decodeString(for: [.about, .bio, .description])
        teachingFocus = container.decodeStringArray(for: [.teachingFocus, .focusAreas, .practices, .tags, .specializations])
        catalogLive = container.decodeString(for: [.catalogLive, .publishedOfferings, .offeringsCount])
        posts = container.decodeString(for: [.posts, .publishedPosts, .postsCount])
        trust = container.decodeString(for: [.trust, .trustScore])
        followers = container.decodeString(for: [.followers, .followerCount])
        retreatsCount = container.decodeString(for: [.retreats, .retreatsCount])
        fee = container.decodeDouble(for: [.fee, .sessionFee, .amount, .price])
        currency = container.decodeString(for: [.currency, .currencyCode, .feeCurrency])
    }
}

private struct MentorEnvelopeDTO: Decodable {
    let catalog: MentorCatalogDTO?
    let session: MentorSessionDTO?
}

struct MentorCatalogDTO: Decodable {
    let items: MentorPageDTO?
    let featured: MentorPageDTO?
}

struct MentorPageDTO: Decodable {
    let content: [MentorItemDTO]
    let page: Int?
    let totalElements: Int?
    let totalPages: Int?
    let last: Bool?

    init(content: [MentorItemDTO], page: Int?, totalElements: Int?, totalPages: Int?, last: Bool?) {
        self.content = content
        self.page = page
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.last = last
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        content = container.decodeArray(for: [.content, .items, .mentors, .results]) ?? []
        page = container.decodeInt(for: [.page, .pageNumber, .number])
        totalElements = container.decodeInt(for: [.totalElements, .numberOfElements, .total, .count])
        totalPages = container.decodeInt(for: [.totalPages, .pages])
        last = container.decodeBool(for: [.last, .isLast])
    }

    var isLast: Bool {
        if let last { return last }
        if let totalPages, let page { return page + 1 >= totalPages }
        return content.isEmpty
    }
}

struct MentorSessionDTO: Decodable {
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let heroImagePath: String?
    let categories: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        eyebrow = container.decodeString(for: [.eyebrow, .label])
        title = container.decodeString(for: [.title, .heading])
        subtitle = container.decodeString(for: [.subtitle, .description])
        heroImagePath = container.decodeImagePath(for: [.heroImage, .image, .backgroundImage])
        categories = container.decodeStringArray(for: [.categories, .filters])
    }
}

struct MentorSectionDTO {
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let heroImagePath: String?
    let categories: [String]
    let page: MentorPageDTO

    init(session: MentorSessionDTO?, page: MentorPageDTO) {
        eyebrow = session?.eyebrow
        title = session?.title
        subtitle = session?.subtitle
        heroImagePath = session?.heroImagePath
        categories = session?.categories ?? []
        self.page = page
    }
}

struct MentorItemDTO: Decodable {
    let id: String?
    let name: String?
    let location: String?
    let lineage: String?
    let experience: String?
    let languages: String?
    let category: String?
    let tags: [String]
    let fee: Double?
    let currency: String?
    let rating: Double?
    let reviewCount: Int?
    let imagePath: String?
    let verified: Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MentorCodingKey.self)
        id = container.decodeString(for: [.id, .mentorId, .uuid])
        name = container.decodeString(for: [.name, .fullName, .spiritualName, .mentorName, .displayName, .title])
        location = container.decodeString(for: [.location, .address, .city, .destination])
        lineage = container.decodeString(for: [.lineage, .spiritualLineage, .tradition, .practice])
        experience = container.decodeString(for: [.experience, .yearsExperience, .years, .experienceYears])
        languages = container.decodeString(for: [.languages, .language, .spokenLanguages])
        category = container.decodeString(for: [.category, .categoryName, .type, .specialization])
        tags = container.decodeStringArray(for: [.categories, .specializations, .expertise, .focusAreas, .practices, .tags])
        fee = container.decodeDouble(for: [.fee, .sessionFee, .amount, .price])
        currency = container.decodeString(for: [.currency, .currencyCode, .feeCurrency])
        rating = container.decodeDouble(for: [.rating, .averageRating, .avgRating, .score])
        reviewCount = container.decodeInt(for: [.reviewCount, .reviews, .ratingsCount])
        imagePath = container.decodeImagePath(for: [.image, .imageUrl, .profilePhotoUrl, .photoUrl, .thumbnailUrl, .gallery])
        verified = container.decodeBool(for: [.verified, .isVerified])
            ?? ((container.decodeString(for: [.verificationStatus, .status]) ?? "").lowercased() == "verified")
    }
}

enum MentorCodingKey: String, CodingKey {
    case data, guru, catalog, featured, items, content, mentors, results, session, eyebrow, label, title, heading, subtitle, description
    case heroImage, image, backgroundImage, categories, filters, page, pageNumber, number, numberOfElements, totalElements, total, count, totalPages, pages, last, isLast
    case id, mentorId, guruId, uuid, name, fullName, spiritualName, mentorName, displayName, location, address, city, destination
    case lineage, spiritualLineage, tradition, practice, experience, yearsExperience, years, experienceYears, headline, tagline
    case languages, language, spokenLanguages, category, categoryName, type, specialization, specializations, expertise, focusAreas, practices, tags, teachingFocus
    case fee, sessionFee, amount, price, currency, currencyCode, feeCurrency
    case rating, averageRating, avgRating, score, reviewCount, reviews, ratingsCount, students, studentCount, since, memberSince, joinedSince
    case imageUrl, profilePhotoUrl, photoUrl, thumbnailUrl, gallery, verified, isVerified, verificationStatus, status, isFeatured
    case about, bio, catalogLive, publishedOfferings, offeringsCount, posts, publishedPosts, postsCount, trust, trustScore, followers, followerCount, retreats, retreatsCount
}

struct MentorImageDTO: Decodable {
    let imageUrl: String?
    let url: String?
    let path: String?
    let src: String?

    var resolvedPath: String? { imageUrl ?? url ?? path ?? src }
}

private extension KeyedDecodingContainer where Key == MentorCodingKey {
    func decodeString(for keys: [Key]) -> String? {
        for key in keys {
            if let value = try? decodeIfPresent(String.self, forKey: key), !value.isEmpty { return value }
        }
        return nil
    }

    func decodeInt(for keys: [Key]) -> Int? {
        for key in keys {
            if let value = try? decodeIfPresent(Int.self, forKey: key) { return value }
            if let value = try? decodeIfPresent(Double.self, forKey: key) { return Int(value) }
        }
        return nil
    }

    func decodeDouble(for keys: [Key]) -> Double? {
        for key in keys {
            if let value = try? decodeIfPresent(Double.self, forKey: key) { return value }
            if let value = try? decodeIfPresent(String.self, forKey: key) { return Double(value) }
        }
        return nil
    }

    func decodeBool(for keys: [Key]) -> Bool? {
        for key in keys {
            if let value = try? decodeIfPresent(Bool.self, forKey: key) { return value }
        }
        return nil
    }

    func decodeStringArray(for keys: [Key]) -> [String] {
        for key in keys {
            if let value = try? decodeIfPresent([String].self, forKey: key) { return value }
        }
        return []
    }

    func decodeArray<T: Decodable>(for keys: [Key]) -> [T]? {
        for key in keys {
            if let value = try? decodeIfPresent([T].self, forKey: key) { return value }
        }
        return nil
    }

    func decodeImagePath(for keys: [Key]) -> String? {
        for key in keys {
            if let path = try? decodeIfPresent(String.self, forKey: key), !path.isEmpty { return path }
            if let image = try? decodeIfPresent(MentorImageDTO.self, forKey: key) { return image.resolvedPath }
            if let images = try? decodeIfPresent([MentorImageDTO].self, forKey: key), let image = images.first { return image.resolvedPath }
        }
        return nil
    }
}

enum MentorDTOMapper {
    static func map(_ dto: MentorResponseDTO) -> MentorSection {
        let source = dto.section
        let items = source.page.content.compactMap { item -> Mentor? in
            guard let name = item.name, !name.isEmpty else { return nil }
            return Mentor(
                id: item.id ?? name,
                name: name,
                location: item.location ?? "",
                lineage: item.lineage ?? "",
                experience: item.experience ?? "",
                languages: item.languages ?? "",
                category: item.category ?? item.tags.first ?? "Mentor",
                tags: item.tags,
                feeLabel: priceLabel(item.fee, currency: item.currency),
                rating: item.rating,
                reviewCount: item.reviewCount,
                imagePath: item.imagePath,
                verified: item.verified ?? false
            )
        }
        let categories = source.categories.isEmpty
            ? ["All Mentors", "Meditation", "Vedic", "Ayurveda", "Yoga", "Jyotish", "Healing"]
            : source.categories
        return MentorSection(
            eyebrow: source.eyebrow ?? "Verified guides",
            title: source.title ?? "Mentors",
            subtitle: source.subtitle ?? "Teachers, acharyas and healers for 1:1 guidance, online or in person.",
            heroImagePath: source.heroImagePath,
            totalCount: source.page.totalElements,
            categories: categories,
            page: MentorPage(items: items, pageNumber: source.page.page ?? 0, totalElements: source.page.totalElements, isLast: source.page.isLast)
        )
    }

    static func mapPage(_ dto: MentorPageResponseDTO) -> MentorPage {
        MentorPage(
            items: dto.page.content.compactMap(map),
            pageNumber: dto.page.page ?? 0,
            totalElements: dto.page.totalElements,
            isLast: dto.page.isLast
        )
    }

    static func mapDetail(_ dto: MentorDetailResponseDTO) -> MentorDetail {
        let source = dto.detail
        let name = source.name ?? "Mentor"
        return MentorDetail(
            id: source.id ?? name,
            name: name,
            imagePath: source.imagePath,
            verified: source.verified,
            featured: source.featured,
            headline: source.headline ?? "",
            lineage: source.lineage ?? "",
            rating: source.rating,
            reviewCount: source.reviewCount,
            experience: source.experience ?? "",
            students: source.students ?? "0",
            since: source.since ?? "",
            languages: source.languages ?? "",
            location: source.location ?? "",
            about: source.about ?? "",
            teachingFocus: source.teachingFocus,
            catalogLive: source.catalogLive ?? "0",
            posts: source.posts ?? "0",
            trust: source.trust ?? "0%",
            followers: source.followers ?? "0",
            retreatsCount: source.retreatsCount ?? "0",
            feeLabel: priceLabel(source.fee, currency: source.currency)
        )
    }

    private static func map(_ item: MentorItemDTO) -> Mentor? {
        guard let name = item.name, !name.isEmpty else { return nil }
        return Mentor(
            id: item.id ?? name,
            name: name,
            location: item.location ?? "",
            lineage: item.lineage ?? "",
            experience: item.experience ?? "",
            languages: item.languages ?? "",
            category: item.category ?? item.tags.first ?? "Mentor",
            tags: item.tags,
            feeLabel: priceLabel(item.fee, currency: item.currency),
            rating: item.rating,
            reviewCount: item.reviewCount,
            imagePath: item.imagePath,
            verified: item.verified ?? false
        )
    }

    private static func priceLabel(_ price: Double?, currency: String?) -> String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let value = formatter.string(from: NSNumber(value: price)) ?? String(Int(price))
        return currency?.uppercased() == "INR" || currency == nil ? "₹\(value)/hr" : "\(currency!) \(value)/hr"
    }
}
