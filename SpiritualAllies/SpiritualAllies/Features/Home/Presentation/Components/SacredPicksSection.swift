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
            SectionHeader(title: picks.title, actionTitle: picks.seeAllLabel, action: onSeeAll)

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
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(AppColor.accentSoft))
                    .padding(12)
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
