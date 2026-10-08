import SwiftUI

struct OfferingDetailView: View {
    @State private var viewModel: OfferingDetailViewModel
    @State private var galleryPresentation: OfferingGalleryPresentation?

    init(viewModel: OfferingDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            content
        }
        .task { await viewModel.onAppear() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.light)
        .fullScreenCover(item: $galleryPresentation) { presentation in
            OfferingGalleryViewer(
                images: presentation.images,
                initialIndex: presentation.initialIndex
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 14) {
                ProgressView().controlSize(.large).tint(AppColor.accent)
                Text("Preparing your sacred offering…")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColor.textSecondary)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Offering unavailable", systemImage: "hands.sparkles")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.primary)
            }
        case .loaded(let offering):
            detailContent(offering)
        }
    }

    private func detailContent(_ offering: OfferingDetail) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                OfferingDetailHero(offering: offering)

                OfferingTrustStrip(offering: offering)
                    .padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 24) {
                    if !offering.description.isEmpty {
                        detailSection(title: "About this offering", icon: "sparkles") {
                            Text(offering.description)
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColor.textSecondary)
                                .lineSpacing(5)
                        }
                    }

                    if !offering.inclusions.isEmpty || !offering.exclusions.isEmpty {
                        detailSection(title: "What to expect", icon: "checkmark.seal") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(offering.inclusions, id: \.self) { item in
                                    detailBullet(item, icon: "checkmark.circle.fill", color: AppColor.primary)
                                }
                                ForEach(offering.exclusions, id: \.self) { item in
                                    detailBullet(item, icon: "minus.circle", color: AppColor.textSecondary)
                                }
                            }
                        }
                    }

                    if let guidance = offering.scheduleHints, !guidance.isEmpty {
                        detailSection(title: "Ritual guidance", icon: "book.closed") {
                            Text(guidance)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColor.textSecondary)
                                .lineSpacing(4)
                        }
                    }

                    if offering.gallery.count > 1 {
                        gallerySection(offering.gallery)
                    }

                    if let policy = offering.cancellationSummary, !policy.isEmpty {
                        detailSection(title: "Booking assurance", icon: "shield.checkered") {
                            VStack(alignment: .leading, spacing: 9) {
                                Text(policy)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColor.textSecondary)
                                    .lineSpacing(3)
                                if offering.fullPaymentRequired {
                                    Label("Full payment confirms your sankalp", systemImage: "lock.shield")
                                        .font(AppFont.caption(13))
                                        .foregroundStyle(AppColor.primary)
                                }
                            }
                        }
                    }

                    if !offering.tags.isEmpty {
                        tags(offering.tags)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bookingBar(offering)
        }
    }

    private func detailSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(AppFont.title(22))
                .foregroundStyle(AppColor.textPrimary)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColor.cardStroke, lineWidth: 1)
                )
        )
    }

    private func detailBullet(_ text: String, icon: String, color: Color) -> some View {
        Label {
            Text(text).fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: icon).foregroundStyle(color)
        }
        .font(AppFont.body(15))
        .foregroundStyle(AppColor.textSecondary)
    }

    private func gallerySection(_ images: [OfferingDetailImage]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Sacred glimpses", systemImage: "photo.on.rectangle.angled")
                .font(AppFont.title(22))
                .foregroundStyle(AppColor.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                        Button {
                            galleryPresentation = OfferingGalleryPresentation(
                                images: images,
                                initialIndex: index
                            )
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                RemoteImage(path: image.thumbnailPath ?? image.imagePath)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 250, height: 165)
                                    .clipped()

                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(Circle().fill(Color.black.opacity(0.55)))
                                    .padding(10)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func tags(_ tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags.filter { !$0.hasPrefix("seed:") }, id: \.self) { tag in
                    Text(tag.replacingOccurrences(of: "-", with: " ").capitalized)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColor.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColor.primary.opacity(0.09)))
                }
            }
        }
    }

    private func bookingBar(_ offering: OfferingDetail) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Offering from")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColor.onDarkSecondary)
                Text(priceLabel(offering))
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(AppColor.onDark)
            }

            Spacer(minLength: 4)

            Button {
                ToastHelper.toast("Booking flow coming soon")
            } label: {
                Label("Book Offering", systemImage: "hands.sparkles")
                    .font(AppFont.heading(16))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .background(Capsule().fill(AppColor.accent))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(AppColor.primaryDark)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColor.accent.opacity(0.28))
                .frame(height: 1)
        }
    }

    private func priceLabel(_ offering: OfferingDetail) -> String {
        guard let price = offering.priceFrom else { return "On request" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = offering.currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(offering.currency) \(Int(price))"
    }
}

private struct OfferingDetailHero: View {
    let offering: OfferingDetail

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                RemoteImage(path: offering.heroImagePath) {
                    LinearGradient(
                        colors: [AppColor.primary, AppColor.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width, height: 440)
                .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.12), AppColor.primaryDark.opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text(offering.category.uppercased())
                        .font(AppFont.eyebrow(11))
                        .tracking(2.2)
                        .foregroundStyle(AppColor.primaryDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AppColor.accentSoft))

                    Text(offering.title)
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)

                    if !offering.summary.isEmpty {
                        Text(offering.summary)
                            .font(AppFont.body(16))
                            .foregroundStyle(.white.opacity(0.88))
                            .lineLimit(3)
                    }

                    if !offering.location.isEmpty {
                        Label(offering.location, systemImage: "mappin.and.ellipse")
                            .font(AppFont.heading(14))
                            .foregroundStyle(AppColor.accentSoft)
                    }
                }
                .frame(width: max(proxy.size.width - 60, 1), alignment: .leading)
                .padding(.leading, 28)
                .padding(.bottom, 24)
            }
            .frame(width: proxy.size.width, height: 440)
        }
        .frame(height: 440)
    }
}

private struct OfferingGalleryPresentation: Identifiable {
    let id = UUID()
    let images: [OfferingDetailImage]
    let initialIndex: Int
}

private struct OfferingGalleryViewer: View {
    let images: [OfferingDetailImage]
    @State private var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(images: [OfferingDetailImage], initialIndex: Int) {
        self.images = images
        _selectedIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                    VStack(spacing: 18) {
                        Spacer(minLength: 80)

                        RemoteImage(path: image.imagePath ?? image.thumbnailPath) {
                            ProgressView()
                                .controlSize(.large)
                                .tint(AppColor.accent)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        if let caption = image.alt, !caption.isEmpty {
                            Text(caption)
                                .font(AppFont.body(14))
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                        }

                        Spacer(minLength: 70)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack {
                HStack {
                    Text("\(selectedIndex + 1) of \(images.count)")
                        .font(AppFont.heading(14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(Capsule().fill(Color.white.opacity(0.14)))

                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(Color.white.opacity(0.14)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)

                Spacer()
            }
        }
        .statusBarHidden(true)
    }
}

private struct OfferingTrustStrip: View {
    let offering: OfferingDetail

    var body: some View {
        HStack(spacing: 0) {
            if let duration = offering.durationMinutes {
                value(icon: "clock", value: "\(duration) min", label: "Duration")
            }
            value(icon: modeIcon, value: modeLabel, label: "Participation")
            if let mentor = offering.mentorName {
                value(icon: offering.mentorVerified ? "checkmark.seal.fill" : "person", value: mentor, label: offering.mentorVerified ? "Verified guide" : "Guide")
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColor.surface)
                .shadow(color: AppColor.shadow, radius: 12, x: 0, y: 6)
        )
    }

    private func value(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.accent)
            Text(value)
                .font(AppFont.heading(13))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(AppFont.caption(10))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var modeLabel: String {
        guard let mode = offering.deliveryModes.first else { return "Flexible" }
        return mode.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private var modeIcon: String {
        switch offering.deliveryModes.first?.uppercased() {
        case "IN_PERSON": return "building.columns"
        case "VIRTUAL": return "video"
        case "AT_HOME": return "house"
        default: return "sparkles"
        }
    }
}
