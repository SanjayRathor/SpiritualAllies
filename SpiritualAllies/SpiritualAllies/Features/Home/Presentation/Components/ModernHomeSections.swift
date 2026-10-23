import SwiftUI

struct HomeCategoryStrip: View {
    let tiles: [HomeOSTile]
    var onTap: (HomeOSTile) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(Array(tiles.prefix(6))) { tile in
                    Button { onTap(tile) } label: {
                        VStack(spacing: 8) {
                            Image(systemName: iconName(tile.icon))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(iconColor(tile.displayOrder))
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(iconColor(tile.displayOrder).opacity(0.11)))

                            Text(shortTitle(tile.title))
                                .font(AppFont.label())
                                .foregroundStyle(AppColor.textPrimary)
                                .lineLimit(1)
                        }
                        .frame(width: 70)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColor.surface)
                .shadow(color: AppColor.primaryDark.opacity(0.08), radius: 16, y: 8)
        )
        .padding(.horizontal, 16)
    }

    private func shortTitle(_ title: String) -> String {
        switch title.lowercased() {
        case "sacred places": return "Temples"
        case "offerings": return "Poojas"
        case "sacred events": return "Events"
        case "mentors": return "Guides"
        default: return title
        }
    }

    private func iconColor(_ index: Int) -> Color {
        [AppColor.primary, .pink, .green, .purple, .red, .teal][abs(index) % 6]
    }

    private func iconName(_ icon: String?) -> String {
        switch icon?.lowercased() {
        case "brain": return "sparkles"
        case "hand-heart": return "hands.sparkles"
        case "users": return "person.2"
        case "landmark": return "building.columns"
        case "calendar", "sparkles": return "calendar"
        case "flower": return "camera.macro"
        default: return "safari"
        }
    }
}

struct HomeFeaturedRow: View {
    let picks: HomeSacredPicks
    var onSeeAll: () -> Void = {}
    var onTapItem: (HomeCatalogItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(picks.title, systemImage: sectionIcon)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColor.primaryDark)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    if !picks.subtitle.isEmpty {
                        Text(picks.subtitle)
                            .font(AppFont.bodySmall())
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 10)
                if !picks.seeAllLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: onSeeAll) {
                        HStack(spacing: 5) {
                            Text("View all")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: AppFontSize.label, weight: .semibold))
                        .foregroundStyle(AppColor.accent)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 3)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(picks.items) { item in
                        Button { onTapItem(item) } label: {
                            featuredCard(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
    }

    private func featuredCard(_ item: HomeCatalogItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImage(path: item.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 208, height: 124)
                    .clipped()

                if !item.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.category)
                        .font(AppFont.caption())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(AppColor.primary.opacity(0.86)))
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: AppFontSize.bodySmall, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !item.location.isEmpty {
                    Label(item.location, systemImage: "mappin.and.ellipse")
                        .font(.system(size: AppFontSize.caption, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                if !item.category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.category)
                        .font(.system(size: AppFontSize.caption, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                HStack {
                    if let price = item.priceLabel {
                        Text(price)
                            .font(.system(size: AppFontSize.label, weight: .semibold))
                            .foregroundStyle(AppColor.accent)
                    } else if let rating = item.rating {
                        Label(String(format: "%.1f", rating), systemImage: "star.fill")
                            .font(AppFont.label())
                            .foregroundStyle(AppColor.accent)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(AppColor.accentSoft.opacity(0.45)))
                }
            }
            .padding(12)
        }
        .frame(width: 208, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(AppColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppColor.cardStroke, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: AppColor.primaryDark.opacity(0.08), radius: 14, y: 7)
    }

    private var sectionIcon: String {
        let title = picks.title.lowercased()
        if title.contains("offering") { return "hands.sparkles" }
        if title.contains("mentor") || title.contains("purohit") { return "person.2" }
        if title.contains("event") { return "calendar" }
        if title.contains("intention") { return "sparkles" }
        return "building.columns"
    }
}
