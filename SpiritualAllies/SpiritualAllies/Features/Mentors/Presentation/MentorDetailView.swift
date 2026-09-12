import SwiftUI

struct MentorDetailView: View {
    let mentor: Mentor
    @State private var viewModel: MentorDetailViewModel

    init(mentor: Mentor, viewModel: MentorDetailViewModel) {
        self.mentor = mentor
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .task { await viewModel.onAppear() }
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().tint(AppColor.primary)
        case .failed(let message):
            VStack(spacing: 14) {
                Text("Unable to load mentor")
                    .font(AppFont.heading(22))
                Text(message)
                    .font(AppFont.body(15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(28)
        case .loaded:
            if let detail = viewModel.detail { detailContent(detail) }
        }
    }

    private func detailContent(_ detail: MentorDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileCard(detail)
                aboutCard(detail)
                retreatsSection(detail)
                actionCard(title: "Mentor circle", subtitle: "Follow to get notified when \(detail.name) publishes teachings.", button: "Follow")
                actionCard(title: "Book a 1:1 session", subtitle: "Schedule personalized guidance with \(detail.name) - share your intent and meet live.", button: "Schedule Assistance", icon: "video")
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(AppColor.background)
    }

    private func profileCard(_ detail: MentorDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            RemoteImage(path: detail.imagePath ?? mentor.imagePath)
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(detail.name)
                    .font(AppFont.title(32))
                    .foregroundStyle(AppColor.textPrimary)
                if detail.verified { badge("checkmark.seal.fill", "Verified guide", color: AppColor.primary) }
            }
            if detail.featured { badge("rosette", "Featured", color: AppColor.accent) }
            if !detail.headline.isEmpty { Text(detail.headline).font(AppFont.body(18)).foregroundStyle(AppColor.textSecondary) }
            if !detail.lineage.isEmpty { Text(detail.lineage).font(AppFont.body(18)).foregroundStyle(AppColor.accent) }
            HStack(spacing: 14) {
                if let rating = detail.rating { metric("star.fill", String(format: "%.1f", rating)) }
                if let reviews = detail.reviewCount { Text("(\(reviews) reviews)").font(AppFont.body(16)).foregroundStyle(AppColor.textSecondary) }
                if !detail.experience.isEmpty { metric("clock", detail.experience) }
            }
            HStack(spacing: 14) {
                if !detail.students.isEmpty { metric("person.2", "\(detail.students) Students") }
                if !detail.since.isEmpty { metric("square.stack.3d.up", "Since \(detail.since)") }
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                stat("CATALOG LIVE", detail.catalogLive, "Published offerings")
                stat("POSTS", detail.posts, "Published teachings")
                stat("TRUST", detail.trust, "Platform verified")
                stat("FOLLOWERS", detail.followers, "Mentor circle")
            }
        }
        .padding(18)
        .foregroundStyle(AppColor.textPrimary)
        .background(cardBackground())
    }

    private func aboutCard(_ detail: MentorDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("About \(detail.name)", systemImage: "book.closed")
                .font(AppFont.title(26)).foregroundStyle(AppColor.primary)
            if !detail.about.isEmpty { Text(detail.about).font(AppFont.body(17)).foregroundStyle(AppColor.textSecondary).lineSpacing(7) }
            if !detail.teachingFocus.isEmpty {
                Text("TEACHING FOCUS").font(AppFont.heading(14)).tracking(1).foregroundStyle(AppColor.textSecondary)
                FlowLayout(items: detail.teachingFocus)
            }
            Divider()
            detailField("LANGUAGES", detail.languages)
            detailField("BASED IN", detail.location, icon: "mappin.and.ellipse")
            Label("Contact", systemImage: "envelope").font(AppFont.body(18)).foregroundStyle(AppColor.primary)
        }
        .padding(20)
        .foregroundStyle(AppColor.textPrimary)
        .background(cardBackground())
    }

    private func retreatsSection(_ detail: MentorDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Retreats", systemImage: "sparkles")
                    .font(AppFont.heading(18))
                    .foregroundStyle(AppColor.primary)
                Spacer()
                Text(detail.retreatsCount)
                    .font(AppFont.heading(15))
                    .foregroundStyle(AppColor.primary)
                    .padding(8)
                    .background(Circle().fill(AppColor.primary.opacity(0.1)))
            }
            Text("Published retreats")
                .font(AppFont.title(25))
                .foregroundStyle(AppColor.textPrimary)
            Text("Immersive programs hosted by this guide - apply or explore details.").font(AppFont.body(17)).foregroundStyle(AppColor.textSecondary)
            Text("No published retreats yet. Check back soon.")
                .font(AppFont.body(16))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(22)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppColor.cardStroke, style: StrokeStyle(lineWidth: 1, dash: [5])))
        }
        .padding(.vertical, 2)
    }

    private func actionCard(title: String, subtitle: String, button: String, icon: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(AppFont.title(25)).foregroundStyle(AppColor.textPrimary)
            Text(subtitle).font(AppFont.body(17)).foregroundStyle(AppColor.textSecondary)
            Label(button, systemImage: icon ?? "person.badge.plus")
                .font(AppFont.heading(17)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 18).fill(AppColor.primary))
        }
        .padding(20).background(cardBackground())
    }

    private func badge(_ icon: String, _ text: String, color: Color) -> some View { Label(text, systemImage: icon).font(AppFont.heading(14)).foregroundStyle(color).padding(.horizontal, 14).padding(.vertical, 8).background(Capsule().fill(color.opacity(0.1))) }
    private func metric(_ icon: String, _ text: String) -> some View { Label(text, systemImage: icon).font(AppFont.body(15)).foregroundStyle(AppColor.textSecondary) }
    private func stat(_ title: String, _ value: String, _ subtitle: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(title).font(AppFont.heading(12)).foregroundStyle(AppColor.textSecondary); Text(value).font(AppFont.title(27)); Text(subtitle).font(AppFont.body(13)).foregroundStyle(AppColor.textSecondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(RoundedRectangle(cornerRadius: 18).fill(AppColor.surface)).shadow(color: AppColor.shadow.opacity(0.1), radius: 4, y: 2) }
    private func detailField(_ title: String, _ value: String, icon: String? = nil) -> some View { VStack(alignment: .leading, spacing: 7) { Text(title).font(AppFont.heading(13)).foregroundStyle(AppColor.textSecondary); if let icon { Label(value, systemImage: icon).font(AppFont.body(17)) } else { Text(value).font(AppFont.body(17)) } } }
    private func cardBackground() -> some View { RoundedRectangle(cornerRadius: 28, style: .continuous).fill(AppColor.surface).overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(AppColor.cardStroke, lineWidth: 1)).shadow(color: AppColor.shadow.opacity(0.1), radius: 12, y: 6) }
}

private struct FlowLayout: View {
    let items: [String]
    var body: some View { LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), alignment: .leading)], alignment: .leading, spacing: 10) { ForEach(items, id: \.self) { Text($0).font(AppFont.body(15)).foregroundStyle(AppColor.primary).padding(.horizontal, 14).padding(.vertical, 8).background(Capsule().fill(AppColor.primary.opacity(0.08))) } } }
}
