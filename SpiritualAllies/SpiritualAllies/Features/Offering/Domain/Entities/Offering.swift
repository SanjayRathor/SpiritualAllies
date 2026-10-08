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

struct OfferingDetail: Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let summary: String
    let category: String
    let ritualType: String
    let deity: String?
    let deliveryModes: [String]
    let durationMinutes: Int?
    let priceFrom: Double?
    let currency: String
    let location: String
    let mentorName: String?
    let mentorVerified: Bool
    let tags: [String]
    let rating: Double?
    let ratingCount: Int?
    let bookingCount: Int?
    let heroImagePath: String?
    let description: String
    let inclusions: [String]
    let exclusions: [String]
    let scheduleHints: String?
    let gallery: [OfferingDetailImage]
    let cancellationSummary: String?
    let fullPaymentRequired: Bool
}

struct OfferingDetailImage: Equatable, Identifiable {
    let thumbnailPath: String?
    let imagePath: String?
    let alt: String?

    var id: String { imagePath ?? thumbnailPath ?? alt ?? "offering-image" }
}
