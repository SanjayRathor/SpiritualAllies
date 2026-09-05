//
//  HomeDashboardDTO.swift
//  SpiritualAllies
//
//  Codable DTOs mirroring the backend JSON (home.json). These are decoding
//  concerns only and are mapped into domain entities by `HomeDTOMapper`.
//  Only the fields needed by the current design are modeled; unknown keys are
//  ignored automatically.
//

import Foundation

// MARK: - Root

/// Top-level response of GET /api/mobile/screen?section=landing.
struct HomeResponseDTO: Decodable {
    let catalog: CatalogDTO?
    let dashboard: DashboardDTO?
}

struct DashboardDTO: Decodable {
    let hero: HeroDTO?
    let stats: [StatDTO]?
    let osSection: OSSectionDTO?
    let sacredPicks: SacredPicksDTO?
    let discoveryCta: DiscoveryCtaDTO?
}

// MARK: - Shared

struct ImageDTO: Decodable {
    let imageUrl: String?
    let alt: String?
}

// MARK: - Hero

struct HeroDTO: Decodable {
    let brandMark: String?
    let brandName: String
    let tagline: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let heroImage: ImageDTO?
    let seek: SeekDTO
}

struct CatalogDTO: Decodable {
    let features: [CatalogFeatureGroupDTO]?
    let analytics: CatalogAnalyticsDTO?
    let path: CatalogPathDTO?
}

struct CatalogAnalyticsDTO: Decodable {
    let stats: [StatDTO]?
}

struct CatalogPathDTO: Decodable {
    let id: String?
    let eyebrow: String?
    let title: String?
    let subtitle: String?
    let tiles: [CatalogPathTileDTO]?
}

struct CatalogPathTileDTO: Decodable {
    let id: String
    let label: String
    let subtitle: String
    let route: String
    let imageUrl: String?
    let icon: String?
    let displayOrder: Int
}

struct CatalogFeatureGroupDTO: Decodable {
    let name: String
    let contents: [CatalogFeatureContentDTO]
    let displayOrder: Int?
}

struct CatalogFeatureContentDTO: Decodable {
    let title: String?
    let desc: String?
    let galleries: [CatalogGalleryDTO]?
    let tags: [String]?
    let displayOrder: Int?
}

struct CatalogGalleryDTO: Decodable {
    let imageUrl: String?
}

struct SeekDTO: Decodable {
    let ctaLabel: String
    let placeholder: String
    let prompts: [String]
}

// MARK: - Stats

struct StatDTO: Decodable {
    let value: String
    let label: String
    let sub: String
    let icon: String
}

// MARK: - OS Section

struct OSSectionDTO: Decodable {
    let eyebrow: String
    let title: String
    let tiles: [OSTileDTO]
}

struct OSTileDTO: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let route: String
    let image: ImageDTO?
    let displayOrder: Int
}

// MARK: - Sacred Picks

struct SacredPicksDTO: Decodable {
    let title: String
    let seeAllLabel: String
    let items: [CatalogItemDTO]
}

struct CatalogItemDTO: Decodable {
    let title: String
    let location: String
    let category: String
    let priceLabel: String?
    let rating: Double?
    let verified: Bool?
    let route: String
    let image: ImageDTO?
}

// MARK: - Discovery CTA

struct DiscoveryCtaDTO: Decodable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let ctaLabel: String
    let backgroundImage: ImageDTO?
}
