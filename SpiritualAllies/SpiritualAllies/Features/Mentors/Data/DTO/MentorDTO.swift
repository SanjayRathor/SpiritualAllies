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
    case data, catalog, featured, items, content, mentors, results, session, eyebrow, label, title, heading, subtitle, description
    case heroImage, image, backgroundImage, categories, filters, page, pageNumber, number, numberOfElements, totalElements, total, count, totalPages, pages, last, isLast
    case id, mentorId, uuid, name, fullName, spiritualName, mentorName, displayName, location, address, city, destination
    case lineage, spiritualLineage, tradition, practice, experience, yearsExperience, years, experienceYears
    case languages, language, spokenLanguages, category, categoryName, type, specialization, specializations, expertise, focusAreas, practices, tags
    case fee, sessionFee, amount, price, currency, currencyCode, feeCurrency
    case rating, averageRating, avgRating, score, reviewCount, reviews, ratingsCount
    case imageUrl, profilePhotoUrl, photoUrl, thumbnailUrl, gallery, verified, isVerified, verificationStatus, status
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

    private static func priceLabel(_ price: Double?, currency: String?) -> String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let value = formatter.string(from: NSNumber(value: price)) ?? String(Int(price))
        return currency?.uppercased() == "INR" || currency == nil ? "₹\(value)/hr" : "\(currency!) \(value)/hr"
    }
}
