//
//  SacredPicksSection.swift
//  SpiritualAllies
//
//  "Sacred picks for you" — a horizontally scrolling row of catalog cards.
//

import SwiftUI

struct SacredPicksSection: View {
    let picks: HomeSacredPicks
    var onSeeAll: () -> Void = {}
    var onTapItem: (HomeCatalogItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                if !picks.eyebrow.isEmpty {
                    Text(picks.eyebrow.uppercased())
                        .font(AppFont.eyebrow(11))
                        .tracking(3.0)
                        .foregroundStyle(AppColor.accent.opacity(0.85))
                }

                SectionHeader(title: picks.title, actionTitle: picks.seeAllLabel, action: onSeeAll)

                if !picks.subtitle.isEmpty {
                    Text(picks.subtitle)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(3)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(picks.items) { item in
                        CatalogCard(item: item)
                            .onTapGesture { onTapItem(item) }
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

/// A bookable catalog card (image, verified badge, title, location, price, rating).
struct CatalogCard: View {
    let item: HomeCatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RemoteImage(path: item.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 272, height: 176)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.clear, AppColor.primaryDark.opacity(0.28)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    )
                if item.verified {
                    VerifiedBadge()
                        .padding(12)
                }
                Text(item.category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(AppColor.primaryDark)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.accentSoft)
                    )
                    .padding(12)
                    .frame(width: 156, alignment: .trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(item.title)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Label(item.location, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColor.textSecondary)
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 112, alignment: .leading)

                Spacer(minLength: 8)

                if let price = item.priceLabel {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                }

                if let rating = item.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.accent)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
        }
        .frame(width: 272, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(AppColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(AppColor.cardStroke.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: AppColor.shadow.opacity(0.14), radius: 20, x: 0, y: 10)
    }
}

struct PanchangSection: View {
    let panchang: HomePanchang

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(panchang.eyebrow.uppercased())
                .font(AppFont.eyebrow(11))
                .tracking(3)
                .foregroundStyle(AppColor.accent)

            Text(panchang.title)
                .font(AppFont.title(26))
                .foregroundStyle(AppColor.textPrimary)

            if !panchang.subtitle.isEmpty {
                Text(panchang.subtitle)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(panchang.date)
                    .font(AppFont.heading(16))
                    .foregroundStyle(AppColor.onDark)
                Text(panchang.hinduDate)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColor.onDarkSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColor.primary)
            )

            if !panchang.pillars.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(panchang.pillars) { pillar in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pillar.label.uppercased())
                                    .font(AppFont.eyebrow(10))
                                    .tracking(1.2)
                                    .foregroundStyle(AppColor.accent)
                                Text(pillar.name)
                                    .font(AppFont.heading(15))
                                    .foregroundStyle(AppColor.textPrimary)
                                if !pillar.detail.isEmpty {
                                    Text(pillar.detail)
                                        .font(AppFont.body(12))
                                        .foregroundStyle(AppColor.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                            .frame(width: 132, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppColor.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(AppColor.cardStroke, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}
