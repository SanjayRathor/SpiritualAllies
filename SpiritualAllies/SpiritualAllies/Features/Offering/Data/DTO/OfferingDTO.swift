//
//  OfferingDTO.swift
//  SpiritualAllies
//

import Foundation

struct OfferingResponseDTO: Decodable {
    let root: OfferingPayloadDTO

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OfferingCodingKey.self)
        let direct = try OfferingPayloadDTO(container: container)
        if let catalog = try? container.decodeIfPresent(OfferingCatalogDTO.self, forKey: .catalog),
           let items = catalog.items {
            root = OfferingPayloadDTO(page: items, session: try? container.decodeIfPresent(OfferingSessionDTO.self, forKey: .session))
        } else if let catalog = try? container.decodeIfPresent(OfferingCatalogDTO.self, forKey: .catalog),
                  let offerings = catalog.offerings {
            root = OfferingPayloadDTO(payload: offerings)
        } else {
            root = direct
        }
    }
}

private struct OfferingCatalogDTO: Decodable {
    let offerings: OfferingNestedPayloadDTO?
    let items: OfferingPagePayloadDTO?
}

private struct OfferingPagePayloadDTO: Decodable {
    let content: [OfferingItemDTO]
    let page: Int?
    let totalElements: Int?
    let totalPages: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OfferingCodingKey.self)
        content = container.decodeArray(for: [.content, .items, .offerings, .results]) ?? []
        page = container.decodeInt(for: [.page, .pageNumber, .number])
        totalElements = container.decodeInt(for: [.totalElements, .total, .count])
        totalPages = container.decodeInt(for: [.totalPages, .pages])
    }

    var isLast: Bool {
        if let totalPages, let page { return page + 1 >= totalPages }
        return content.isEmpty
    }
}

private struct OfferingSessionDTO: Decodable {
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let heroImagePath: String?
    let categories: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OfferingCodingKey.self)
        eyebrow = container.decodeString(for: [.eyebrow, .label])
        title = container.decodeString(for: [.title, .heading])
        subtitle = container.decodeString(for: [.subtitle, .description])
        heroImagePath = container.decodeImagePath(for: [.heroImage, .image, .backgroundImage])
        categories = container.decodeStringArray(for: [.categories, .filters])
    }
}

struct OfferingPayloadDTO {
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let heroImagePath: String?
    let totalCount: Int?
    let categories: [String]
    let content: [OfferingItemDTO]
    let pageNumber: Int
    let totalElements: Int?
    let isLast: Bool

    fileprivate init(page: OfferingPagePayloadDTO, session: OfferingSessionDTO?) {
        eyebrow = session?.eyebrow
        title = session?.title
        subtitle = session?.subtitle
        heroImagePath = session?.heroImagePath
        totalCount = page.totalElements
        categories = session?.categories ?? []
        content = page.content
        pageNumber = page.page ?? 0
        totalElements = page.totalElements
        isLast = page.isLast
    }

    fileprivate init(payload: OfferingNestedPayloadDTO) {
        eyebrow = payload.eyebrow
        title = payload.title
        subtitle = payload.subtitle
        heroImagePath = payload.heroImagePath
        totalCount = payload.totalCount
        categories = payload.categories
        content = payload.content
        pageNumber = payload.pageNumber ?? 0
        totalElements = payload.totalElements
        isLast = payload.isLast ?? payload.content.isEmpty
    }

    init(container: KeyedDecodingContainer<OfferingCodingKey>) throws {
        let payload = (try? container.decodeIfPresent(OfferingNestedPayloadDTO.self, forKey: .data))
            ?? (try? container.decodeIfPresent(OfferingNestedPayloadDTO.self, forKey: .section))
            ?? (try? container.decodeIfPresent(OfferingNestedPayloadDTO.self, forKey: .screen))
            ?? (try? container.decodeIfPresent(OfferingNestedPayloadDTO.self, forKey: .catalog))

        eyebrow = payload?.eyebrow ?? container.decodeString(for: [.eyebrow, .label])
        title = payload?.title ?? container.decodeString(for: [.title, .heading])
        subtitle = payload?.subtitle ?? container.decodeString(for: [.subtitle, .description])
        heroImagePath = payload?.heroImagePath ?? container.decodeImagePath(for: [.heroImage, .image, .backgroundImage])
        totalCount = payload?.totalCount ?? container.decodeInt(for: [.totalElements, .total, .count])
        categories = payload?.categories ?? container.decodeStringArray(for: [.categories, .filters])
        content = payload?.content ?? container.decodeArray(for: [.content, .items, .offerings, .results, .data]) ?? []
        pageNumber = payload?.pageNumber ?? container.decodeInt(for: [.page, .pageNumber, .number]) ?? 0
        totalElements = payload?.totalElements ?? container.decodeInt(for: [.totalElements, .total, .count])
        isLast = payload?.isLast ?? container.decodeBool(for: [.isLast, .last]) ?? content.isEmpty
    }
}

private struct OfferingNestedPayloadDTO: Decodable {
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let heroImagePath: String?
    let totalCount: Int?
    let categories: [String]
    let content: [OfferingItemDTO]
    let pageNumber: Int?
    let totalElements: Int?
    let isLast: Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OfferingCodingKey.self)
        eyebrow = container.decodeString(for: [.eyebrow, .label])
        title = container.decodeString(for: [.title, .heading])
        subtitle = container.decodeString(for: [.subtitle, .description])
        heroImagePath = container.decodeImagePath(for: [.heroImage, .image, .backgroundImage])
        totalCount = container.decodeInt(for: [.totalElements, .total, .count])
        categories = container.decodeStringArray(for: [.categories, .filters])
        content = container.decodeArray(for: [.content, .items, .offerings, .results, .data]) ?? []
        pageNumber = container.decodeInt(for: [.page, .pageNumber, .number])
        totalElements = container.decodeInt(for: [.totalElements, .total, .count])
        isLast = container.decodeBool(for: [.isLast, .last])
    }
}

struct OfferingItemDTO: Decodable {
    let id: String?
    let title: String?
    let location: String?
    let details: String?
    let category: String?
    let price: Double?
    let currency: String?
    let rating: Double?
    let imagePath: String?
    let verified: Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OfferingCodingKey.self)
        id = container.decodeString(for: [.id, .offeringId, .uuid])
        title = container.decodeString(for: [.title, .name, .offeringName])
        location = container.decodeString(for: [.location, .templeName, .venue, .destination, .address])
        details = container.decodeString(for: [.details, .description, .schedule, .timing, .duration])
        category = container.decodeString(for: [.category, .categoryName, .type, .tag])
        price = container.decodeDouble(for: [.price, .basePrice, .amount, .pricePerPerson])
        currency = container.decodeString(for: [.currency, .currencyCode, .priceCurrency])
        rating = container.decodeDouble(for: [.rating, .averageRating, .avgRating, .score])
        imagePath = container.decodeImagePath(for: [.image, .imageUrl, .thumbnailUrl, .coverImageUrl, .photoUrl, .gallery])
        verified = container.decodeBool(for: [.verified, .isVerified])
            ?? ((container.decodeString(for: [.verificationStatus, .status]) ?? "").lowercased() == "verified")
    }
}

enum OfferingCodingKey: String, CodingKey {
    case data, catalog, section, screen, session, eyebrow, label, title, heading, subtitle, description
    case heroImage, image, backgroundImage, totalElements, total, count
    case categories, filters, content, items, offerings, results
    case page, pageNumber, number, pageSize, totalPages, pages, isLast, last
    case id, offeringId, uuid, name, offeringName, location, templeName, venue
    case destination, address, details, schedule, timing, duration, category
    case categoryName, type, tag, price, basePrice, amount, pricePerPerson
    case currency, currencyCode, priceCurrency, rating, averageRating, avgRating, score
    case imageUrl, thumbnailUrl, coverImageUrl, photoUrl, gallery, verified
    case isVerified, verificationStatus, status
}

private extension KeyedDecodingContainer where Key == OfferingCodingKey {
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
            if let values = try? decodeIfPresent([String].self, forKey: key) { return values }
        }
        return []
    }

    func decodeArray<T: Decodable>(for keys: [Key]) -> [T]? {
        for key in keys {
            if let values = try? decodeIfPresent([T].self, forKey: key) { return values }
        }
        return nil
    }

    func decodeImagePath(for keys: [Key]) -> String? {
        for key in keys {
            if let path = try? decodeIfPresent(String.self, forKey: key), !path.isEmpty { return path }
            if let image = try? decodeIfPresent(OfferingImageDTO.self, forKey: key) { return image.resolvedPath }
            if let images = try? decodeIfPresent([OfferingImageDTO].self, forKey: key), let image = images.first { return image.resolvedPath }
        }
        return nil
    }
}

private struct OfferingImageDTO: Decodable {
    let imageUrl: String?
    let url: String?
    let path: String?
    let src: String?

    var resolvedPath: String? { imageUrl ?? url ?? path ?? src }
}

enum OfferingDTOMapper {
    static func map(_ dto: OfferingResponseDTO) -> OfferingSection {
        let payload = dto.root
        let items = payload.content.compactMap { item -> Offering? in
            guard let title = item.title, !title.isEmpty else { return nil }
            return Offering(
                id: item.id ?? title,
                title: title,
                location: item.location ?? "",
                details: item.details ?? "",
                category: item.category ?? "Offering",
                priceLabel: priceLabel(item.price, currency: item.currency),
                rating: item.rating,
                imagePath: item.imagePath,
                verified: item.verified ?? false
            )
        }

        let categories = payload.categories.isEmpty
            ? ["All Offerings", "Pooja", "Homa / Havan", "Abhishekam", "Archana", "Temple Seva", "Annadanam", "Donations", "Festivals", "Personalized Blessings"]
            : payload.categories

        return OfferingSection(
            eyebrow: payload.eyebrow ?? "Bookable now",
            title: payload.title ?? "Sacred Offerings & Seva",
            subtitle: payload.subtitle ?? "Book poojas, havans, archana, and temple seva with verified priests and mentors.",
            heroImagePath: payload.heroImagePath,
            totalCount: payload.totalCount ?? payload.totalElements,
            categories: categories,
            page: OfferingPage(items: items, pageNumber: payload.pageNumber, totalElements: payload.totalElements, isLast: payload.isLast)
        )
    }

    private static func priceLabel(_ price: Double?, currency: String?) -> String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: price)) ?? String(Int(price))
        return currency?.uppercased() == "INR" || currency == nil ? "₹\(formatted)" : "\(currency!) \(formatted)"
    }
}
