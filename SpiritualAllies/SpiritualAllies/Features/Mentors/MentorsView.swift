import SwiftUI
import Observation
import UIKit

struct MentorsView: View {
    @State private var viewModel: MentorViewModel

    init(viewModel: MentorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            content
        }
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
                Image(systemName: "person.2.slash")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
                Text("Unable to load mentors")
                    .font(AppFont.heading(20))
                    .foregroundStyle(AppColor.textPrimary)
                Text(message)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Retry") { Task { await viewModel.refresh() } }
                    .font(AppFont.heading(15))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(AppColor.accent))
            }
            .padding(28)
        case .loaded:
            loadedContent
        }
    }

    private var loadedContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                if let section = viewModel.section {
                    MentorHero(section: section)
                        .padding(.horizontal, -16)
                }

                MentorSearchField(text: $viewModel.searchText)
                mentorCategories

                Text(viewModel.resultCountText)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColor.textSecondary)

                if viewModel.filteredMentors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No mentors found")
                            .font(AppFont.title(23))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("Try another category or search term.")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.vertical, 30)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredMentors) { mentor in
                            MentorRowCard(mentor: mentor)
                                .task { await viewModel.loadMoreIfNeeded(current: mentor) }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 110)
        }
        .refreshable { await viewModel.refresh() }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
    }

    private var mentorCategories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedCategory = category }
                    } label: {
                        Text(category)
                            .font(AppFont.heading(15))
                            .foregroundStyle(viewModel.selectedCategory == category ? AppColor.onDark : AppColor.primary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(viewModel.selectedCategory == category ? AppColor.primary : AppColor.surface))
                            .overlay(Capsule().stroke(AppColor.cardStroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct MentorSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(AppColor.textSecondary)
            TextField("Search mentors by name, tradition, or practice...", text: $text)
                .font(AppFont.body(16))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.textSecondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 58)
        .background(Capsule().fill(AppColor.surface))
        .overlay(Capsule().stroke(AppColor.cardStroke, lineWidth: 1))
    }
}

private struct MentorHero: View {
    let section: MentorSection

    private var safeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imagePath = section.heroImagePath {
                RemoteImage(path: imagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 410)
                    .clipped()
            } else {
                LinearGradient(colors: [AppColor.primaryDark, AppColor.primary], startPoint: .topLeading, endPoint: .bottomTrailing)
            }

            LinearGradient(colors: [.clear, Color.black.opacity(0.14), AppColor.primaryDark.opacity(0.92)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("श्री")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(AppColor.primaryDark.opacity(0.7)))
                        .overlay(Circle().stroke(AppColor.accent.opacity(0.7), lineWidth: 1))
                    Spacer()
                    Image(systemName: "bell")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(AppColor.accentSoft)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(AppColor.primaryDark.opacity(0.7)))
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }

                Spacer(minLength: 0)
                Text("\(section.totalCount ?? 0) VERIFIED GUIDES")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .tracking(2.6)
                    .foregroundStyle(AppColor.accentSoft)
                Text(section.title)
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                Text(section.subtitle)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
            }
            .padding(.top, safeTopInset + 14)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .frame(height: 410)
        .ignoresSafeArea(edges: .top)
    }
}

private struct MentorRowCard: View {
    let mentor: Mentor

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RemoteImage(path: mentor.imagePath)
                .aspectRatio(contentMode: .fill)
                .frame(width: 112, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top, spacing: 8) {
                    Text(mentor.name)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    if mentor.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(AppColor.primary)
                    }
                }

                let firstLine = [mentor.location, mentor.lineage]
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
                if !firstLine.isEmpty {
                    Text(firstLine)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                let secondLine = [mentor.experience, mentor.languages]
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
                if !secondLine.isEmpty {
                    Text(secondLine)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                HStack(alignment: .firstTextBaseline) {
                    if let fee = mentor.feeLabel {
                        Text(fee)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    Spacer(minLength: 4)
                    if let rating = mentor.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(AppColor.accent)
                            Text(String(format: "%.1f", rating)).foregroundStyle(AppColor.textSecondary)
                        }
                        .font(AppFont.heading(14))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColor.surface)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(AppColor.cardStroke, lineWidth: 1))
        )
        .shadow(color: AppColor.shadow.opacity(0.11), radius: 16, x: 0, y: 8)
    }
}
