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
        SectionSurface {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(title: picks.title, actionTitle: picks.seeAllLabel, action: onSeeAll)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(picks.items) { item in
                            CatalogCard(item: item)
                                .onTapGesture { onTapItem(item) }
                        }
                    }
                }
            }
        }
    }
}

/// A bookable catalog card (image, verified badge, title, location, price, rating).
struct CatalogCard: View {
    let item: HomeCatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack(alignment: .topLeading) {
                RemoteImage(path: item.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.clear, AppColor.primaryDark.opacity(0.24)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )
                if item.verified {
                    VerifiedBadge().padding(AppSpacing.sm)
                }
                Text(item.category.uppercased())
                    .font(AppFont.eyebrow(10))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(AppColor.accentSoft))
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(item.title)
                .font(AppFont.heading(17))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Label(item.location, systemImage: "mappin.and.ellipse")
                .font(AppFont.caption(12))
                .foregroundStyle(AppColor.textSecondary)
                .labelStyle(.titleAndIcon)

            HStack {
                if let price = item.priceLabel {
                    Text(price)
                        .font(AppFont.heading(16))
                        .foregroundStyle(AppColor.textPrimary)
                }
                Spacer()
                if let rating = item.rating {
                    RatingLabel(rating: rating)
                }
            }
        }
        .frame(width: 250, alignment: .leading)
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardStroke, lineWidth: 1)
        )
        .shadow(color: AppColor.shadow.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}
