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
            stats: dashboard?.stats?.map(mapStat)
                ?? dto.catalog?.analytics?.stats?.map(mapStat)
                ?? [],
            osSection: dashboard?.osSection.map(mapOSSection)
                ?? mapPath(dto.catalog?.path),
            sacredPicks: dashboard?.sacredPicks.map(mapSacredPicks)
                ?? mapOfferings(dto.catalog?.offerings),
            sacredEvents: mapSacredEvents(dto.catalog?.sacredEvents),
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

    private static func mapOSSection(_ dto: OSSectionDTO) -> HomeOSSection {
        return HomeOSSection(
            eyebrow: dto.eyebrow,
            title: dto.title,
            subtitle: "",
            tiles: dto.tiles
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { HomeOSTile(id: $0.id, title: $0.title, subtitle: $0.subtitle, icon: nil, imagePath: $0.image?.imageUrl, route: $0.route, displayOrder: $0.displayOrder) }
        )
    }

    private static func mapPath(_ dto: CatalogPathDTO?) -> HomeOSSection {
        guard let dto else { return HomeOSSection(eyebrow: "", title: "", subtitle: "", tiles: []) }
        return HomeOSSection(
            eyebrow: dto.eyebrow ?? "SpiritualAllies OS",
            title: dto.title ?? "Everything Your Path Needs",
            subtitle: dto.subtitle ?? "",
            tiles: (dto.tiles ?? [])
                .sorted { $0.displayOrder < $1.displayOrder }
                .map {
                    HomeOSTile(
                        id: $0.id,
                        title: $0.label,
                        subtitle: $0.subtitle,
                        icon: $0.icon,
                        imagePath: $0.imageUrl,
                        route: $0.route,
                        displayOrder: $0.displayOrder
                    )
                }
        )
    }

    private static func mapSacredPicks(_ dto: SacredPicksDTO?) -> HomeSacredPicks {
        guard let dto else { return HomeSacredPicks(eyebrow: "", title: "", subtitle: "", seeAllLabel: "", items: []) }
        return HomeSacredPicks(
            eyebrow: "",
            title: dto.title,
            subtitle: "",
            seeAllLabel: dto.seeAllLabel,
            items: dto.items.map(mapCatalogItem)
        )
    }

    private static func mapOfferings(_ dto: CatalogOfferingsDTO?) -> HomeSacredPicks {
        guard let dto else { return HomeSacredPicks(eyebrow: "", title: "", subtitle: "", seeAllLabel: "", items: []) }
        return HomeSacredPicks(
            eyebrow: dto.eyebrow ?? "Bookable now",
            title: dto.title ?? "Sacred Offerings & Seva",
            subtitle: dto.subtitle ?? "",
            seeAllLabel: dto.seeAllLabel ?? "Browse offerings",
            items: (dto.items ?? []).compactMap { item in
                guard let name = item.name, !name.isEmpty else { return nil }
                return HomeCatalogItem(
                    title: name,
                    location: item.templeName ?? "",
                    category: item.category ?? "Offering",
                    priceLabel: priceLabel(item.basePrice, currencyCode: item.currencyCode),
                    rating: item.averageRating,
                    verified: item.status?.caseInsensitiveCompare("PUBLISHED") == .orderedSame,
                    imagePath: item.imageUrl,
                    route: item.id.map { "/offerings/\($0)" } ?? "/offerings"
                )
            }
        )
    }

    private static func mapSacredEvents(_ dto: CatalogSacredEventsDTO?) -> HomeSacredPicks {
        guard let dto else { return HomeSacredPicks(eyebrow: "", title: "", subtitle: "", seeAllLabel: "", items: []) }
        return HomeSacredPicks(
            eyebrow: dto.eyebrow ?? "Living traditions",
            title: dto.title ?? "Sacred Events",
            subtitle: dto.subtitle ?? "",
            seeAllLabel: dto.seeAllLabel ?? "Browse sacred events",
            items: (dto.items ?? []).compactMap { item in
                guard let title = item.title, !title.isEmpty else { return nil }
                return HomeCatalogItem(
                    title: title,
                    location: item.eventVenue ?? item.destination ?? "",
                    category: item.categories?.split(separator: ",").first.map(String.init) ?? "Event",
                    priceLabel: priceLabel(item.pricePerPerson, currencyCode: "INR"),
                    rating: nil,
                    verified: item.status?.caseInsensitiveCompare("SCHEDULED") == .orderedSame,
                    imagePath: item.galleryUrls?.split(separator: ",").first.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) },
                    route: item.id.map { "/sacred-events/\($0)" } ?? "/sacred-events"
                )
            }
        )
    }

    private static func priceLabel(_ price: Double?, currencyCode: String?) -> String? {
        guard let price else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: price)) ?? String(Int(price))
        guard let currencyCode, currencyCode != "INR" else { return "₹\(formatted)" }
        return "\(currencyCode) \(formatted)"
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
