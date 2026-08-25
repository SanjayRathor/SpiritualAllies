//
//  SacredPlace.swift
//  SpiritualAllies
//
//  Domain entities for the Places tab.
//

import Foundation

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
}
