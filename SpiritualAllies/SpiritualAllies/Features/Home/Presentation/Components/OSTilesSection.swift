//
//  OSTilesSection.swift
//  SpiritualAllies
//
//  "SpiritualAllies OS — Everything your path needs" grid. The first tile is
//  featured full-width; the rest flow in a two-column grid.
//

import SwiftUI

struct OSTilesSection: View {
    let section: HomeOSSection
    var onTap: (HomeOSTile) -> Void = { _ in }

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        SectionSurface {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(section.eyebrow.uppercased())
                        .font(AppFont.eyebrow(11))
                        .tracking(2)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(section.title)
                        .font(AppFont.heading(25))
                        .foregroundStyle(AppColor.textPrimary)
                }

                if let featured = section.tiles.first {
                    tile(featured, height: 170)
                        .onTapGesture { onTap(featured) }
                }

                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(section.tiles.dropFirst()) { item in
                        tile(item, height: 132)
                            .onTapGesture { onTap(item) }
                    }
                }
            }
        }
    }

    private func tile(_ tile: HomeOSTile, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                RemoteImage(path: tile.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            LinearGradient(
                colors: [.clear, AppColor.primaryDark.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(tile.title)
                        .font(AppFont.heading(17))
                        .foregroundStyle(AppColor.onDark)
                    Text(tile.subtitle)
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColor.onDarkSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColor.onDark)
                    .padding(6)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            .padding(AppSpacing.md)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: AppColor.shadow.opacity(0.16), radius: 16, x: 0, y: 10)
    }
}
