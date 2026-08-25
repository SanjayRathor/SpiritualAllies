//
//  PlacesView.swift
//  SpiritualAllies
//
//  Places tab with paging and category chips.
//

import SwiftUI
import Observation
import UIKit

struct PlacesView: View {
    @State private var viewModel: PlacesViewModel

    init(viewModel: PlacesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            background
            content
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.filteredPlaces.count)
        .task { await viewModel.onAppear() }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            Color.clear
        case .failed(let message):
            errorState(message)
        case .loaded:
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    PlacesHeroView(
                        place: viewModel.heroPlace,
                        countText: viewModel.heroCountText
                    )

                    categoryChips

                    if viewModel.filteredPlaces.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.filteredPlaces) { place in
                                SacredPlaceRowCard(place: place)
                                    .task {
                                        await viewModel.loadMoreIfNeeded(current: place)
                                    }
                            }
                        }
                    }

                    if viewModel.isLoadingMore {
                        loadingMoreFooter
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.availableCategories, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(
                                viewModel.selectedCategory == category
                                ? AppColor.onDark
                                : AppColor.primaryDark
                            )
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(
                                    viewModel.selectedCategory == category
                                    ? AppColor.primary
                                    : Color.white
                                )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(AppColor.cardStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No places found")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)
            Text("Try a different category or pull to refresh.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 24)
    }

    private var loadingMoreFooter: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(AppColor.accent)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(AppColor.accent)

            Text("common.error.generic")
                .font(AppFont.heading(20))
                .foregroundStyle(AppColor.textPrimary)

            Text(message)
                .font(AppFont.body(14))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.refresh() }
            } label: {
                Text("common.retry")
                    .font(AppFont.caption(15))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Capsule().fill(AppColor.accent))
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppColor.cardStroke, lineWidth: 1)
                )
                .shadow(color: AppColor.shadow.opacity(0.12), radius: 24, x: 0, y: 12)
        )
        .padding(.horizontal, AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0xFFF8EC),
                    AppColor.background,
                    Color(hex: 0xE7E1D4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppColor.accent.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: 150, y: -160)

            Circle()
                .fill(AppColor.primary.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 38)
                .offset(x: -150, y: 620)
        }
    }
}

private struct PlacesHeroView: View {
    let place: SacredPlace?
    let countText: String

    private var safeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                ZStack {
                    if let imagePath = place?.imagePath {
                        RemoteImage(path: imagePath)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    } else {
                        LinearGradient(
                            colors: [AppColor.primary, AppColor.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            }
            .frame(height: 390)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.28),
                    AppColor.primaryDark.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("श्री")
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(AppColor.accent)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(AppColor.primary.opacity(0.65)))
                        .overlay(Circle().stroke(AppColor.accent.opacity(0.45), lineWidth: 1))

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColor.accentSoft)
                            .frame(width: 42, height: 42)
                            .background(Circle().fill(AppColor.primaryDark.opacity(0.55)))
                            .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 0)

                Text("\(countText) • VERIFIED")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .tracking(3.2)
                    .foregroundStyle(AppColor.accentSoft)

                Text("Sacred Places")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.onDark)
                    .lineLimit(1)

                Text("Temples, ghats and ashrams — timings, rituals and how to reach them.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColor.onDarkSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 28)
            }
            .padding(.top, safeTopInset + 14)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(height: 390)
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .ignoresSafeArea(edges: .top)
    }
}

private struct SacredPlaceRowCard: View {
    let place: SacredPlace

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RemoteImage(path: place.imagePath)
                .aspectRatio(contentMode: .fill)
                .frame(width: 112, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(place.title)
                    .font(.system(size: 23, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(place.location)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                Text(place.detailsLine.isEmpty ? place.category : place.detailsLine)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    if let rating = place.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColor.accent)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppColor.cardStroke, lineWidth: 1)
                )
        )
        .shadow(color: AppColor.shadow.opacity(0.10), radius: 16, x: 0, y: 8)
    }
}
