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
        let heroes = mapFeatures(dto.catalog?.features)
            ?? dashboard?.hero.map { [mapHero($0)] }
            ?? []

        return HomeDashboard(
            heroes: heroes,
            stats: dashboard?.stats?.map(mapStat) ?? [],
            osSection: mapOSSection(dashboard?.osSection),
            sacredPicks: mapSacredPicks(dashboard?.sacredPicks),
            discoveryCTA: mapDiscoveryCTA(dashboard?.discoveryCta)
        )
    }

    private static func mapFeatures(_ groups: [CatalogFeatureGroupDTO]?) -> [HomeHero]? {
        guard let groups, !groups.isEmpty else { return nil }
        let seekGroup = groups.first { $0.name.caseInsensitiveCompare("Seek") == .orderedSame }
        let group = seekGroup ?? groups.sorted { ($0.displayOrder ?? 0) < ($1.displayOrder ?? 0) }.first
        return group?.contents
            .sorted { ($0.displayOrder ?? 0) < ($1.displayOrder ?? 0) }
            .compactMap { mapFeature($0, groupName: group?.name ?? "Sacred Discovery") }
    }

    private static func mapFeature(_ dto: CatalogFeatureContentDTO, groupName: String) -> HomeHero? {
        guard let title = dto.title, !title.isEmpty else { return nil }
        return HomeHero(
            brandMark: "श्री",
            brandName: "SpiritualAllies",
            tagline: "Transform · Heal · Awaken",
            eyebrow: groupName,
            title: title,
            subtitle: dto.desc ?? "Explore a path that meets you where you are.",
            heroImagePath: dto.galleries?.first?.imageUrl,
            searchPlaceholder: "What is your heart seeking?",
            searchActionLabel: "Seek",
            prompts: dto.tags ?? []
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

    private static func mapOSSection(_ dto: OSSectionDTO?) -> HomeOSSection {
        guard let dto else { return HomeOSSection(eyebrow: "", title: "", tiles: []) }
        return HomeOSSection(
            eyebrow: dto.eyebrow,
            title: dto.title,
            tiles: dto.tiles
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { HomeOSTile(id: $0.id, title: $0.title, subtitle: $0.subtitle, imagePath: $0.image?.imageUrl, route: $0.route, displayOrder: $0.displayOrder) }
        )
    }

    private static func mapSacredPicks(_ dto: SacredPicksDTO?) -> HomeSacredPicks {
        guard let dto else { return HomeSacredPicks(title: "", seeAllLabel: "", items: []) }
        return HomeSacredPicks(
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

    private static func mapDiscoveryCTA(_ dto: DiscoveryCtaDTO?) -> HomeDiscoveryCTA {
        guard let dto else { return HomeDiscoveryCTA(eyebrow: "", title: "", subtitle: "", ctaLabel: "", backgroundImagePath: nil) }
        return HomeDiscoveryCTA(
            eyebrow: dto.eyebrow,
            title: dto.title,
            subtitle: dto.subtitle,
            ctaLabel: dto.ctaLabel,
            backgroundImagePath: dto.backgroundImage?.imageUrl
        )
    }
}
