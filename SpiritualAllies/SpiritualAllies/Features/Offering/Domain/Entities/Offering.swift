//
//  Offering.swift
//  SpiritualAllies
//

import Foundation

struct OfferingSection: Equatable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let heroImagePath: String?
    let totalCount: Int?
    let categories: [String]
    let page: OfferingPage
}

struct OfferingPage: Equatable {
    let items: [Offering]
    let pageNumber: Int
    let totalElements: Int?
    let isLast: Bool

    var hasMore: Bool {
        if let totalElements {
            return (pageNumber + 1) * max(items.count, 1) < totalElements && !isLast
        }
        return !isLast
    }
}

struct Offering: Equatable, Identifiable {
    let id: String
    let title: String
    let location: String
    let details: String
    let category: String
    let priceLabel: String?
    let rating: Double?
    let imagePath: String?
    let verified: Bool
}
