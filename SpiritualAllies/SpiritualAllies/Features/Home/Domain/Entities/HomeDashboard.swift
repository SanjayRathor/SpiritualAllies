//
//  HomeDashboard.swift
//  SpiritualAllies
//
//  Domain entities for the Home screen. These are pure, framework-free value
//  types that the Presentation layer consumes. They are decoupled from the
//  network/JSON shape (which lives in the Data layer as DTOs).
//

import Foundation

/// The full Home dashboard model (subset matching the current design).
struct HomeDashboard: Equatable {
    let hero: HomeHero
    let stats: [HomeStat]
    let osSection: HomeOSSection
    let sacredPicks: HomeSacredPicks
    let discoveryCTA: HomeDiscoveryCTA
}

struct HomeHero: Equatable {
    let brandMark: String
    let brandName: String
    let tagline: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let heroImagePath: String?
    let searchPlaceholder: String
    let searchActionLabel: String
    /// Quick-suggestion chips shown under the search field.
    let prompts: [String]
}

struct HomeStat: Equatable, Identifiable {
    let id = UUID()
    let value: String
    let label: String
    let sub: String
    let icon: String
}

struct HomeOSSection: Equatable {
    let eyebrow: String
    let title: String
    let tiles: [HomeOSTile]
}

struct HomeOSTile: Equatable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imagePath: String?
    let route: String
    let displayOrder: Int
}

struct HomeSacredPicks: Equatable {
    let title: String
    let seeAllLabel: String
    let items: [HomeCatalogItem]
}

/// A generic bookable catalog card (offering / retreat / event / place).
struct HomeCatalogItem: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let category: String
    let priceLabel: String?
    let rating: Double?
    let verified: Bool
    let imagePath: String?
    let route: String
}

struct HomeDiscoveryCTA: Equatable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let ctaLabel: String
    let backgroundImagePath: String?
}
