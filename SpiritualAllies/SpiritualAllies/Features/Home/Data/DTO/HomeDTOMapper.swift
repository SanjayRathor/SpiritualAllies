//
//  HomeDTOMapper.swift
//  SpiritualAllies
//
//  Translates network DTOs into domain entities, keeping the two shapes
//  independent so backend changes don't ripple into the UI.
//

import Foundation

enum HomeDTOMapper {
    static func map(_ dto: HomeResponseDTO) -> HomeDashboard {
        let dashboard = dto.dashboard
        return HomeDashboard(
            hero: mapHero(dashboard.hero),
            stats: dashboard.stats.map(mapStat),
            osSection: mapOSSection(dashboard.osSection),
            sacredPicks: mapSacredPicks(dashboard.sacredPicks),
            discoveryCTA: mapDiscoveryCTA(dashboard.discoveryCta)
        )
    }

    private static func mapHero(_ dto: HeroDTO) -> HomeHero {
        HomeHero(
            brandMark: dto.brandMark ?? "श्री",
            brandName: dto.brandName,
            tagline: dto.tagline,
            eyebrow: dto.eyebrow,
            title: dto.title,
            subtitle: dto.subtitle,
            heroImagePath: dto.heroImage?.imageUrl,
            searchPlaceholder: dto.seek.placeholder,
            searchActionLabel: dto.seek.ctaLabel,
            prompts: dto.seek.prompts
        )
    }

    private static func mapStat(_ dto: StatDTO) -> HomeStat {
        HomeStat(value: dto.value, label: dto.label, sub: dto.sub, icon: dto.icon)
    }

    private static func mapOSSection(_ dto: OSSectionDTO) -> HomeOSSection {
        HomeOSSection(
            eyebrow: dto.eyebrow,
            title: dto.title,
            tiles: dto.tiles
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { HomeOSTile(id: $0.id, title: $0.title, subtitle: $0.subtitle, imagePath: $0.image?.imageUrl, route: $0.route, displayOrder: $0.displayOrder) }
        )
    }

    private static func mapSacredPicks(_ dto: SacredPicksDTO) -> HomeSacredPicks {
        HomeSacredPicks(
            title: dto.title,
            seeAllLabel: dto.seeAllLabel,
            items: dto.items.map(mapCatalogItem)
        )
    }

    private static func mapCatalogItem(_ dto: CatalogItemDTO) -> HomeCatalogItem {
        HomeCatalogItem(
            title: dto.title,
            location: dto.location,
            category: dto.category,
            priceLabel: dto.priceLabel,
            rating: dto.rating,
            verified: dto.verified ?? false,
            imagePath: dto.image?.imageUrl,
            route: dto.route
        )
    }

    private static func mapDiscoveryCTA(_ dto: DiscoveryCtaDTO) -> HomeDiscoveryCTA {
        HomeDiscoveryCTA(
            eyebrow: dto.eyebrow,
            title: dto.title,
            subtitle: dto.subtitle,
            ctaLabel: dto.ctaLabel,
            backgroundImagePath: dto.backgroundImage?.imageUrl
        )
    }
}
