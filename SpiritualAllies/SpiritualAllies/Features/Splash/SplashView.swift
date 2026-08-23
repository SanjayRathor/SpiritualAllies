//
//  SplashView.swift
//  SpiritualAllies
//
//  Branded launch screen. Performs a silent login via SplashViewModel and
//  reports readiness back to the parent through `onReady`.
//

import SwiftUI

struct SplashView: View {
    @State private var viewModel: SplashViewModel
    @State private var animate = false
    let onReady: () -> Void

    init(viewModel: SplashViewModel, onReady: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onReady = onReady
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.primary, AppColor.primaryDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Text("श्री")
                    .font(.system(size: 64, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.accent)
                    .scaleEffect(animate ? 1 : 0.8)
                    .opacity(animate ? 1 : 0)

                Text("SpiritualAllies")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.onDark)

                Text("splash.tagline")
                    .font(AppFont.caption(13))
                    .tracking(1.5)
                    .foregroundStyle(AppColor.onDarkSecondary)

                statusView
                    .padding(.top, AppSpacing.lg)
            }
            .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { animate = true }
        }
        .task { await viewModel.start() }
        .onChange(of: viewModel.state) { _, state in
            if state == .ready { onReady() }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch viewModel.state {
        case .authenticating, .ready:
            ProgressView().tint(AppColor.accent)
        case .failed(let message):
            VStack(spacing: AppSpacing.sm) {
                Text(message)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColor.onDarkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                Button {
                    Task { await viewModel.start() }
                } label: {
                    Text("common.retry")
                        .font(AppFont.caption(15))
                        .foregroundStyle(AppColor.primaryDark)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.sm)
                        .background(Capsule().fill(AppColor.accent))
                }
            }
        }
    }
}
