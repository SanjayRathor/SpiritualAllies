import SwiftUI

struct SpiritualStepDetailView: View {
    let step: HomeCatalogItem
    let makeSearchViewModel: (String) -> SearchViewModel

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    hero
                    meaningCard
                    guidanceCard
                    continueCard
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
                RemoteImage(path: step.imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: 430)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.12), AppColor.primaryDark.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("STEP \(stepNumber)")
                        .font(AppFont.eyebrow(12))
                        .tracking(2.5)
                        .foregroundStyle(AppColor.primaryDark)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColor.accentSoft))

                    Text(step.title)
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(step.location)
                        .font(AppFont.body(17))
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: max(proxy.size.width - 48, 1), alignment: .leading)
                .padding(.leading, 24)
                .padding(.bottom, 30)
            }
            .frame(width: proxy.size.width, height: 430)
        }
        .frame(height: 430)
    }

    private var meaningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(sectionTitle, systemImage: stepIcon)
                .font(AppFont.title(23))
                .foregroundStyle(AppColor.textPrimary)

            Text(stepMeaning)
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

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What this means for you")
                .font(AppFont.title(22))
                .foregroundStyle(AppColor.textPrimary)

            ForEach(guidance, id: \.title) { item in
                HStack(alignment: .top, spacing: 13) {
                    Image(systemName: item.icon)
                        .font(.system(size: 15, weight: .semibold))
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
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .padding(.horizontal, 18)
    }

    private var continueCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Begin with your intention")
                .font(AppFont.title(23))
                .foregroundStyle(.white)

            Text("Tell AI Seek what is calling you today. It will explore trusted offerings, places, and guides across SpiritualAllies.")
                .font(AppFont.body(15))
                .foregroundStyle(.white.opacity(0.78))
                .lineSpacing(4)

            NavigationLink {
                SearchResultsView(viewModel: makeSearchViewModel(searchPrompt))
            } label: {
                Label("Open AI Seek", systemImage: "sparkles")
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

    private var stepNumber: String {
        let digits = step.category.filter(\.isNumber)
        return digits.isEmpty ? "01" : digits
    }

    private var stepKey: String { step.title.lowercased() }

    private var stepIcon: String {
        if stepKey.contains("express") { return "quote.bubble" }
        if stepKey.contains("discover") { return "safari" }
        if stepKey.contains("choose") { return "checkmark.seal" }
        return "figure.walk"
    }

    private var sectionTitle: String {
        if stepKey.contains("express") { return "Your calling matters" }
        if stepKey.contains("discover") { return "Discovery with direction" }
        if stepKey.contains("choose") { return "Trust before commitment" }
        return "From insight to experience"
    }

    private var stepMeaning: String {
        if stepKey.contains("express") {
            return "You do not need to know the name of a ritual, retreat, or tradition. Begin with honest words—what you are carrying, what you hope to change, or what you feel drawn toward."
        }
        if stepKey.contains("discover") {
            return "AI Seek interprets your intention and explores across offerings, mentors, sacred places, retreats, and journeys. The goal is not more choices, but more relevant ones."
        }
        if stepKey.contains("choose") {
            return "Review the meaning, guide, venue, practical details, and price before deciding. SpiritualAllies is designed to make sacred choices feel informed, respectful, and transparent."
        }
        return "A spiritual path becomes meaningful when it is lived. Book the experience that feels right, arrive with intention, and leave space to integrate what it opens within you."
    }

    private var guidance: [(icon: String, title: String, detail: String)] {
        if stepKey.contains("express") {
            return [
                ("heart.text.square", "Use your own words", "There is no special vocabulary required."),
                ("scope", "Name what matters", "Share an intention, concern, celebration, or calling."),
                ("lock.shield", "Stay in control", "You decide which recommendations to explore further.")
            ]
        }
        if stepKey.contains("discover") {
            return [
                ("square.stack.3d.up", "Explore across paths", "See relevant rituals, places, guides, and experiences together."),
                ("wand.and.stars", "Receive meaningful matches", "Recommendations reflect the language and intention you shared."),
                ("arrow.triangle.branch", "Consider alternatives", "Discover paths you may not have known to search for.")
            ]
        }
        if stepKey.contains("choose") {
            return [
                ("checkmark.seal", "Verified context", "Understand who guides the experience and where it takes place."),
                ("doc.text.magnifyingglass", "Clear details", "Review inclusions, guidance, pricing, and policies."),
                ("heart", "Choose what resonates", "Move forward only when the path feels right for you.")
            ]
        }
        return [
            ("calendar", "Prepare thoughtfully", "Follow the practical and spiritual guidance for your experience."),
            ("hands.sparkles", "Participate with intention", "Bring your attention, openness, and personal sankalp."),
            ("leaf", "Integrate gently", "Allow time afterward for reflection and lasting change.")
        ]
    }

    private var searchPrompt: String {
        "Help me discover a spiritual path based on what I am seeking"
    }
}
