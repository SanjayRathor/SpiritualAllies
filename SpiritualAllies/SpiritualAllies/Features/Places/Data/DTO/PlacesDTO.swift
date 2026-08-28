//
//  PlacesDTO.swift
//  SpiritualAllies
//
//  Codable DTOs for GET /sacred-places/public?page=&size=.
//  The decoder is intentionally tolerant so minor backend field-name changes
//  do not break the Places tab.
//

import Foundation

struct SacredPlacesPageDTO: Decodable {
    let content: [SacredPlaceDTO]
    let pageNumber: Int
    let pageSize: Int
    let totalPages: Int?
    let totalElements: Int?
    let isLast: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        content = container.decodeArray(for: [
            "content",
            "items",
            "places",
            "results",
            "data"
        ]) ?? []

        pageNumber = container.decodeInt(for: [
            "number",
            "page",
            "pageNumber",
            "currentPage"
        ]) ?? 0

        pageSize = container.decodeInt(for: [
            "size",
            "pageSize"
        ]) ?? content.count

        totalPages = container.decodeInt(for: [
            "totalPages",
            "pages"
        ])

        totalElements = container.decodeInt(for: [
            "totalElements",
            "total",
            "count"
        ])

        if let last = container.decodeBool(for: ["last", "isLast"]) {
            isLast = last
        } else if let totalPages {
            isLast = pageNumber + 1 >= totalPages
        } else if let totalElements, pageSize > 0 {
            isLast = (pageNumber + 1) * pageSize >= totalElements
        } else {
            isLast = content.count < pageSize
        }
    }
}

struct SacredPlaceDTO: Decodable {
    let id: String
    let title: String
    let location: String
    let category: String
    let timing: String
    let rating: Double?
    let verified: Bool
    let imagePath: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        id = container.decodeString(for: ["id", "placeId", "uuid"]) ?? UUID().uuidString
        title = container.decodeString(for: [
            "title",
            "name",
            "placeName",
            "sacredPlaceName",
            "templeName"
        ]) ?? "Sacred Place"

        location = container.decodeString(for: [
            "location",
            "address",
            "fullAddress"
        ]) ?? Self.joinedLocation(
            city: container.decodeString(for: ["city", "district", "town"]),
            state: container.decodeString(for: ["state", "province"]),
            fallback: container.decodeString(for: ["location"])
        )

        category = container.decodeString(for: [
            "category",
            "type",
            "placeType",
            "categoryName",
            "tag"
        ]) ?? "Sacred Place"

        timing = container.decodeString(for: [
            "timing",
            "timings",
            "hours",
            "openHours",
            "visitHours",
            "schedule"
        ]) ?? ""

        rating = container.decodeDouble(for: [
            "rating",
            "averageRating",
            "avgRating",
            "score"
        ])

        verified = container.decodeBool(for: [
            "verified",
            "isVerified"
        ]) ?? container.decodeVerificationStatus(for: [
            "verificationStatus",
            "status"
        ]) ?? false

        imagePath = container.decodeImagePath(for: [
            "imageUrl",
            "imageURL",
            "coverImageUrl",
            "thumbnailUrl",
            "photoUrl",
            "heroImageUrl",
            "image",
            "coverImage",
            "thumbnail",
            "photo",
            "picture",
            "heroImage"
        ])
    }

    private static func joinedLocation(city: String?, state: String?, fallback: String?) -> String {
        let parts = [city, state].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if !parts.isEmpty {
            return parts.joined(separator: ", ")
        }
        return fallback?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

private struct PlaceImageDTO: Decodable {
    let imageUrl: String?
    let url: String?
    let path: String?
    let src: String?

    var resolvedPath: String? {
        imageUrl ?? url ?? path ?? src
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

private extension KeyedDecodingContainer where Key == DynamicCodingKey {
    func decodeString(for keys: [String]) -> String? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!

            if let value = try? decode(String.self, forKey: codingKey) {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }

            if let number = try? decode(Double.self, forKey: codingKey) {
                return String(number)
            }

            if let nested = try? decode(PlaceImageDTO.self, forKey: codingKey),
               let resolved = nested.resolvedPath?.trimmingCharacters(in: .whitespacesAndNewlines),
               !resolved.isEmpty {
                return resolved
            }
        }
        return nil
    }

    func decodeInt(for keys: [String]) -> Int? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let value = try? decode(Int.self, forKey: codingKey) { return value }
            if let value = try? decode(Double.self, forKey: codingKey) { return Int(value) }
            if let value = try? decode(String.self, forKey: codingKey), let intValue = Int(value) {
                return intValue
            }
        }
        return nil
    }

    func decodeDouble(for keys: [String]) -> Double? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let value = try? decode(Double.self, forKey: codingKey) { return value }
            if let value = try? decode(Int.self, forKey: codingKey) { return Double(value) }
            if let value = try? decode(String.self, forKey: codingKey), let doubleValue = Double(value) {
                return doubleValue
            }
        }
        return nil
    }

    func decodeBool(for keys: [String]) -> Bool? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let value = try? decode(Bool.self, forKey: codingKey) { return value }
            if let value = try? decode(String.self, forKey: codingKey) {
                let lowered = value.lowercased()
                if ["true", "1", "yes"].contains(lowered) { return true }
                if ["false", "0", "no"].contains(lowered) { return false }
            }
        }
        return nil
    }

    func decodeArray<T: Decodable>(for keys: [String]) -> [T]? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let values = try? decode([T].self, forKey: codingKey) {
                return values
            }
        }
        return nil
    }

    func decodeImagePath(for keys: [String]) -> String? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!

            if let value = try? decode(String.self, forKey: codingKey) {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }

            if let nested = try? decode(PlaceImageDTO.self, forKey: codingKey),
               let resolved = nested.resolvedPath?.trimmingCharacters(in: .whitespacesAndNewlines),
               !resolved.isEmpty {
                return resolved
            }

            if let nestedArray = try? decode([PlaceImageDTO].self, forKey: codingKey),
               let resolved = nestedArray
                .compactMap({ $0.resolvedPath?.trimmingCharacters(in: .whitespacesAndNewlines) })
                .first(where: { !$0.isEmpty }) {
                return resolved
            }
        }
        return nil
    }

    func decodeVerificationStatus(for keys: [String]) -> Bool? {
        for key in keys {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let value = try? decode(String.self, forKey: codingKey) {
                let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                if ["VERIFIED", "APPROVED", "PUBLISHED", "ACTIVE"].contains(normalized) {
                    return true
                }
                if ["PENDING", "UNVERIFIED", "REJECTED", "INACTIVE"].contains(normalized) {
                    return false
                }
            }
        }
        return nil
    }
}
