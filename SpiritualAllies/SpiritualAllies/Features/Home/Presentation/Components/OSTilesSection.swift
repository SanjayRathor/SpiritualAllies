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
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 34) {
            VStack(alignment: .leading, spacing: 14) {
                Text(section.eyebrow.uppercased())
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .tracking(4.5)
                    .foregroundStyle(AppColor.textSecondary.opacity(0.9))

                Text(section.title)
                    .font(.system(size: 31, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let featured = section.tiles.first {
                tile(featured, height: 230, featured: true)
                    .onTapGesture { onTap(featured) }
            }

            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(section.tiles.dropFirst()) { item in
                    tile(item, height: 154, featured: false)
                        .onTapGesture { onTap(item) }
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.top, 4)
    }

    private func tile(_ tile: HomeOSTile, height: CGFloat, featured: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                RemoteImage(path: tile.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            LinearGradient(
                colors: [
                    .clear,
                    AppColor.primaryDark.opacity(featured ? 0.28 : 0.18),
                    AppColor.primaryDark.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay {
                if featured {
                    LinearGradient(
                        colors: [Color.black.opacity(0.10), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(tile.title)
                    .font(.system(size: featured ? 20 : 15, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.onDark)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Text(tile.subtitle)
                    .font(.system(size: featured ? 18 : 13, weight: .medium))
                    .foregroundStyle(AppColor.onDarkSecondary)
                    .lineLimit(featured ? 3 : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .padding(.trailing, 52)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColor.accentSoft)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.black.opacity(0.28)))
                .padding(.top, 18)
                .padding(.trailing, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: featured ? 36 : 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: featured ? 36 : 30, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: AppColor.shadow.opacity(featured ? 0.22 : 0.18), radius: featured ? 22 : 18, x: 0, y: 12)
    }
}
