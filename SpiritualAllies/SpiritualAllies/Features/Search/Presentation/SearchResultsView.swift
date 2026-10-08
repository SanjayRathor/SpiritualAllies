import SwiftUI

struct SearchResultsView: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            content
        }
        .navigationTitle("Seek")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(AppColor.primary)
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search places, rituals, mentors…"
        )
        .onSubmit(of: .search) {
            Task { await viewModel.search() }
        }
        .task { await viewModel.onAppear() }
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.accent)
                Text("Seeking spiritual matches…")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColor.textSecondary)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Search unavailable", systemImage: "exclamationmark.magnifyingglass")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.search() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.primary)
            }
        case .loaded(let response):
            if response.results.isEmpty {
                ContentUnavailableView.search(text: response.prompt)
            } else {
                resultsList(response)
            }
        }
    }

    private func resultsList(_ response: SpiritualSearchResponse) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recommended for you")
                        .font(AppFont.title(25))
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(response.results.count) matches for “\(response.prompt)”")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(response.results) { result in
                    SearchResultCard(result: result)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

private struct SearchResultCard: View {
    let result: SpiritualSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImage(path: result.thumbnailPath) {
                    placeholder
                }
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()

                Text(kindLabel)
                    .font(AppFont.eyebrow(10))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppColor.accentSoft))
                    .padding(12)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title)
                            .font(AppFont.heading(19))
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        if !result.subtitle.isEmpty {
                            Label(result.subtitle, systemImage: "mappin.and.ellipse")
                                .font(AppFont.body(13))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }

                    Spacer(minLength: 8)

                    if let price = priceLabel {
                        Text(price)
                            .font(AppFont.heading(16))
                            .foregroundStyle(AppColor.primary)
                            .fixedSize()
                    }
                }

                if !result.summary.isEmpty {
                    Text(result.summary)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(3)
                }

                if !result.pros.isEmpty {
                    SearchBenefitsFlowLayout(spacing: 8) {
                        ForEach(result.pros.prefix(4), id: \.self) { benefit in
                            Label(benefit, systemImage: "checkmark")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColor.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppColor.primary.opacity(0.08))
                                )
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColor.cardStroke, lineWidth: 1)
        )
        .shadow(color: AppColor.shadow, radius: 12, x: 0, y: 6)
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.primary.opacity(0.92), AppColor.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: kindIcon)
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(AppColor.accent)
        }
    }

    private var kindLabel: String {
        result.kind.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private var kindIcon: String {
        switch result.kind.uppercased() {
        case "OFFERING": return "hands.sparkles"
        case "SACRED_PLACE": return "building.columns"
        case "MENTOR": return "person.crop.circle"
        case "PACKAGE": return "map"
        default: return "sparkles"
        }
    }

    private var priceLabel: String? {
        guard let price = result.priceFrom else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = result.currency ?? "INR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price))
    }
}

/// Wraps benefit tags onto additional lines instead of clipping them at the
/// card edge. Long labels may use multiple lines while retaining their badge.
private struct SearchBenefitsFlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(
            proposal: ProposedViewSize(width: bounds.width, height: proposal.height),
            subviews: subviews
        )
        for (index, point) in result.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: result.widths[index], height: nil)
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> Result {
        let maximumWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var widths: [CGFloat] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let naturalSize = subview.sizeThatFits(.unspecified)
            let itemWidth = min(naturalSize.width, maximumWidth)
            let itemSize = subview.sizeThatFits(
                ProposedViewSize(width: itemWidth, height: nil)
            )

            if x > 0, x + itemWidth > maximumWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            points.append(CGPoint(x: x, y: y))
            widths.append(itemWidth)
            x += itemWidth + spacing
            rowHeight = max(rowHeight, itemSize.height)
        }

        return Result(
            size: CGSize(width: maximumWidth.isFinite ? maximumWidth : x, height: y + rowHeight),
            points: points,
            widths: widths
        )
    }

    private struct Result {
        let size: CGSize
        let points: [CGPoint]
        let widths: [CGFloat]
    }
}
