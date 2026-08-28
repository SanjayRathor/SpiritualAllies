//
//  SacredPlace.swift
//  SpiritualAllies
//
//  Domain entities for the Places tab.
//

import Foundation

enum SacredPlaceCategory: String, CaseIterable, Identifiable, Equatable {
    case all = "All Sacred Places"
    case temple = "Temple"
    case gurudwara = "Gurudwara"
    case church = "Church"
    case ashram = "Ashram"
    case monastery = "Monastery"
    case dargah = "Dargah"
    case other = "Other"

    var id: String { rawValue }

    static func classify(_ source: String) -> SacredPlaceCategory {
        let value = source
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if value.contains("gurudwara") || value.contains("gurdwara") {
            return .gurudwara
        }
        if value.contains("church") || value.contains("cathedral") || value.contains("basilica") {
            return .church
        }
        if value.contains("ashram") {
            return .ashram
        }
        if value.contains("monastery") || value.contains("math") || value.contains("matha") || value.contains("mutt") {
            return .monastery
        }
        if value.contains("dargah") || value.contains("mazar") || value.contains("shrine") {
            return .dargah
        }
        if value.contains("temple")
            || value.contains("mandir")
            || value.contains("jyotirlinga")
            || value.contains("shakti peeth")
            || value.contains("devi peeth")
            || value.contains("vishwanath")
            || value.contains("mahadev") {
            return .temple
        }

        return .other
    }
}

struct SacredPlacePage: Equatable {
    let items: [SacredPlace]
    let pageNumber: Int
    let totalPages: Int?
    let totalElements: Int?
    let isLast: Bool

    var hasMore: Bool {
        if let totalPages {
            return pageNumber + 1 < totalPages
        }
        return !isLast
    }
}

struct SacredPlace: Equatable, Identifiable {
    let id: String
    let title: String
    let location: String
    let category: String
    let timing: String
    let rating: Double?
    let verified: Bool
    let imagePath: String?

    var detailsLine: String {
        [category, timing]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var categoryFilter: SacredPlaceCategory {
        SacredPlaceCategory.classify(category)
    }

    func matches(_ filter: SacredPlaceCategory) -> Bool {
        filter == .all || categoryFilter == filter
    }
}
