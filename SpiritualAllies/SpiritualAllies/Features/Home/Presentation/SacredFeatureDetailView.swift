import SwiftUI

struct SacredFeatureDetailView: View {
    let feature: HomeOSTile
    let onExploreOfferings: () -> Void

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        hero
                        messageCard
                            .padding(.horizontal, 20)
                            .offset(y: -34)
                    }
                    .frame(width: proxy.size.width)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(edges: .top)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                RemoteImage(path: feature.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: 430)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.14), AppColor.primaryDark.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: systemIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppColor.primary.opacity(0.88))
                        )

                    Text(feature.title)
                        .font(.system(size: 39, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(feature.subtitle)
                        .font(AppFont.body(18))
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: max(proxy.size.width - 48, 1), alignment: .leading)
                .padding(.leading, 24)
                .padding(.bottom, 62)
            }
            .frame(width: proxy.size.width, height: 430)
        }
        .frame(height: 430)
    }

    private var messageCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColor.accentSoft.opacity(0.55))
                    .frame(width: 70, height: 70)
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColor.primary)
            }

            Text(messageTitle)
                .font(AppFont.title(25))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(messageBody)
                .font(AppFont.body(16))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onExploreOfferings) {
                Label("Explore Sacred Offerings", systemImage: "hands.sparkles")
                    .font(AppFont.heading(15))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Capsule().fill(AppColor.accent))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(AppColor.cardStroke, lineWidth: 1)
                )
                .shadow(color: AppColor.shadow, radius: 18, x: 0, y: 10)
        )
    }

    private var whatToExpect: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What you’ll discover here")
                .font(AppFont.title(22))
                .foregroundStyle(AppColor.textPrimary)

            ForEach(expectations, id: \.title) { item in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(AppColor.primary))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(AppFont.heading(15))
                            .foregroundStyle(AppColor.textPrimary)
                        Text(item.detail)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppColor.surfaceAlt)
        )
    }

    private var featureKey: String {
        "\(feature.id) \(feature.title) \(feature.route)".lowercased()
    }

    private var systemIcon: String {
        if featureKey.contains("event") { return "sparkles" }
        if featureKey.contains("retreat") { return "leaf" }
        if featureKey.contains("pilgrim") { return "building.columns" }
        if featureKey.contains("experience") { return "figure.mind.and.body" }
        if featureKey.contains("journey") { return "safari" }
        return "star.circle"
    }

    private var messageTitle: String {
        "Verified \(feature.title.lowercased()) are coming soon"
    }

    private var messageBody: String {
        if featureKey.contains("event") {
            return "We’re gathering trusted dates, sacred venues, ceremony details, and participation guidance so you can join living traditions with confidence."
        }
        if featureKey.contains("retreat") {
            return "We’re carefully reviewing teachers, locations, daily practices, accommodation, and wellbeing standards before opening retreat bookings."
        }
        if featureKey.contains("pilgrim") {
            return "We’re preparing complete sacred circuits with verified temples, thoughtful itineraries, local guidance, and dependable travel support."
        }
        if featureKey.contains("experience") {
            return "Meaningful short-form practices, workshops, and spiritual activities are being curated with trusted local hosts and mentors."
        }
        if featureKey.contains("journey") {
            return "Guided paths for lasting spiritual growth are being designed with clear milestones, trusted mentors, and space for reflection."
        }
        return "This sacred collection is being thoughtfully curated and verified. Please return soon to discover experiences chosen with care."
    }

    private var expectations: [(icon: String, title: String, detail: String)] {
        [
            ("checkmark.seal", "Trusted and verified", "Clear host, guide, venue, and tradition information."),
            ("calendar", "Practical details", "Dates, duration, participation options, and what to expect."),
            ("heart", "Meaningful context", "The spiritual significance and intention behind every experience.")
        ]
    }
}
