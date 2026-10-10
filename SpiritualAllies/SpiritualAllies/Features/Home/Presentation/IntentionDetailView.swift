import SwiftUI
import Foundation

struct IntentionDetailView: View {
    let intention: HomeCatalogItem
    let makeSearchViewModel: (String) -> SearchViewModel

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    hero
                    introduction
                    pathsSection
                    seekCard
                }
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.light)
    }

    private var hero: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                RemoteImage(path: intention.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: 430)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.08), AppColor.primaryDark.opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: intentionIcon)
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 58, height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppColor.primary.opacity(0.9))
                        )

                    Text("YOUR INTENTION")
                        .font(AppFont.eyebrow(11))
                        .tracking(2.4)
                        .foregroundStyle(AppColor.accentSoft)

                    Text(intention.title)
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text(intention.location)
                        .font(AppFont.body(18))
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(3)
                }
                .frame(width: max(proxy.size.width - 48, 1), alignment: .leading)
                .padding(.leading, 24)
                .padding(.bottom, 30)
            }
            .frame(width: proxy.size.width, height: 430)
        }
        .frame(height: 430)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("A path shaped around you", systemImage: "sparkles")
                .font(AppFont.title(23))
                .foregroundStyle(AppColor.textPrimary)

            Text(intentionMeaning)
                .font(AppFont.body(16))
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .padding(.horizontal, 18)
    }

    private var pathsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Paths you may explore")
                .font(AppFont.title(23))
                .foregroundStyle(AppColor.textPrimary)

            ForEach(suggestedPaths, id: \.title) { path in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: path.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(AppColor.primary))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(path.title)
                            .font(AppFont.heading(16))
                            .foregroundStyle(AppColor.textPrimary)
                        Text(path.detail)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .padding(.horizontal, 18)
    }

    private var seekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Not sure where to begin?")
                .font(AppFont.title(24))
                .foregroundStyle(.white)

            Text("AI Seek can explore offerings, sacred places, mentors, and journeys that align with your intention.")
                .font(AppFont.body(15))
                .foregroundStyle(.white.opacity(0.78))
                .lineSpacing(4)

            Text("“\(searchPrompt)”")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(AppColor.accentSoft)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )

            NavigationLink {
                SearchResultsView(viewModel: makeSearchViewModel(searchPrompt))
            } label: {
                Label("Ask AI Seek", systemImage: "sparkles")
                    .font(AppFont.heading(16))
                    .foregroundStyle(AppColor.primaryDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Capsule().fill(AppColor.accent))
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColor.primaryDark)
        )
        .padding(.horizontal, 18)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(AppColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(AppColor.cardStroke, lineWidth: 1)
            )
            .shadow(color: AppColor.shadow.opacity(0.7), radius: 14, x: 0, y: 7)
    }

    private var intentionKey: String { intention.title.lowercased() }

    private var intentionIcon: String {
        if intentionKey.contains("peace") || intentionKey.contains("meditation") { return "moon.stars" }
        if intentionKey.contains("healing") { return "heart" }
        if intentionKey.contains("ayurveda") || intentionKey.contains("detox") { return "leaf" }
        if intentionKey.contains("devotion") { return "flame" }
        if intentionKey.contains("growth") { return "tree" }
        return "sparkles"
    }

    private var intentionMeaning: String {
        switch intentionKey {
        case let key where key.contains("rejuvenation"):
            return "Rejuvenation is an invitation to restore depleted energy and reconnect with the steadiness already within you. Your path may combine rest, sacred surroundings, mindful movement, and time-honoured healing practices."
        case let key where key.contains("peace") || key.contains("stress"):
            return "Peace begins by creating space between you and the noise. Gentle practices, supportive guides, and sacred environments can help the mind soften and the nervous system return to balance."
        case let key where key.contains("healing"):
            return "Healing is personal and rarely linear. This intention brings together compassionate guidance, restorative practices, ritual, and places that support renewal of body, mind, and spirit."
        case let key where key.contains("ayurveda") || key.contains("detox"):
            return "Traditional cleansing and balancing practices can help you return to a more natural rhythm. Explore thoughtful experiences rooted in Ayurveda, nourishment, rest, and mindful daily ritual."
        case let key where key.contains("meditation"):
            return "Meditation offers a way to meet life with greater clarity and presence. Find teachers, retreats, and practices suited to your experience, pace, and spiritual temperament."
        case let key where key.contains("devotion"):
            return "Devotion transforms feeling into sacred action. Discover rituals, offerings, temples, and guides that help express gratitude, prayer, remembrance, and loving connection."
        default:
            return "Every spiritual intention is deeply personal. We’ll help you explore trusted practices, places, offerings, and mentors that resonate with what your heart is seeking now."
        }
    }

    private var suggestedPaths: [(icon: String, title: String, detail: String)] {
        [
            ("person.2", "Guidance", "Connect with trusted mentors whose experience aligns with your intention."),
            ("building.columns", "Sacred places", "Discover environments that create space for reflection, ritual, and renewal."),
            ("hands.sparkles", "Practices and offerings", "Explore meaningful rituals and practices you can begin with confidence.")
        ]
    }

    private var searchPrompt: String {
        let components = URLComponents(string: intention.route)?.queryItems
        if let query = components?.first(where: { $0.name == "q" })?.value, !query.isEmpty {
            return query.replacingOccurrences(of: "+", with: " ")
        }
        return "Help me find a spiritual path for \(intention.title.lowercased())"
    }
}
