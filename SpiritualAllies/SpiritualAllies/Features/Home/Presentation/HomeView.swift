//
//  HomeView.swift
//  SpiritualAllies
//
//  Composes the Home dashboard sections and handles loading / error states.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            background
            content
        }
        .animation(.easeInOut(duration: 0.6), value: viewModel.state)
        .task { await viewModel.onAppear() }
        // The hero photo bleeds behind the status bar, so force light
        // (white) status bar content for this screen specifically.
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            // Loading is shown via ToastHelper's themed HUD; keep the canvas clean.
            Color.clear
        case .failed(let message):
            errorView(message)
        case .loaded(let dashboard):
            dashboardScroll(dashboard)
                .transition(.opacity)          // dissolve in when data arrives
        }
    }

    private func dashboardScroll(_ dashboard: HomeDashboard) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                HeroSection(slides: dashboard.heroes, searchText: $viewModel.searchText)

                if !dashboard.stats.isEmpty {
                    StatsSection(stats: dashboard.stats)
                }

                if !dashboard.osSection.tiles.isEmpty {
                    OSTilesSection(section: dashboard.osSection)
                }

                if !dashboard.sacredPicks.items.isEmpty {
                    SacredPicksSection(picks: dashboard.sacredPicks)
                }

                if !dashboard.discoveryCTA.title.isEmpty {
                    DiscoveryCTASection(cta: dashboard.discoveryCTA)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 120)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
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
                Task { await viewModel.load() }
            } label: {
                Text("common.retry")
                    .font(AppFont.caption(15))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Capsule().fill(AppColor.accent))
            }
            .padding(.top, AppSpacing.xs)
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
                .fill(AppColor.accent.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 28)
                .offset(x: 140, y: -180)

            Circle()
                .fill(AppColor.primary.opacity(0.14))
                .frame(width: 340, height: 340)
                .blur(radius: 40)
                .offset(x: -150, y: 560)
        }
    }
}
