//
//  HeroSection.swift
//  SpiritualAllies
//
//  Rebuilt hero with explicit outer padding and inset image/card layout.
//  The goal is to keep the right edge visibly inset and avoid clipping.
//

import SwiftUI

struct HeroSection: View {
    let hero: HomeHero
    @Binding var searchText: String
    var onSeek: () -> Void = {}
    var onPromptTap: (String) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            heroCard
            promptChips
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Overlaid directly on the hero image now, so it always renders on
    /// dark imagery — colors are tuned for that, not the cream background.
    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(hero.brandMark)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColor.accent)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AppColor.primary.opacity(0.65)))
                .overlay(Circle().stroke(AppColor.accent.opacity(0.5), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(hero.brandName.isEmpty ? "SpiritualAllies" : hero.brandName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.onDark)
                Text(hero.tagline.uppercased())
                    .font(AppFont.eyebrow(10))
                    .tracking(2.0)
                    .foregroundStyle(AppColor.onDarkSecondary)
            }

            Spacer(minLength: 8)

            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColor.accentSoft)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColor.primaryDark.opacity(0.55)))
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .top) {
            // Background layers bleed past the top safe area so the photo
            // sits behind the status bar / notch, edge-to-edge.
            GeometryReader { proxy in
                RemoteImage(path: hero.heroImagePath)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea(edges: .top)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.12),
                    AppColor.primaryDark.opacity(0.05),
                    AppColor.primaryDark.opacity(0.42),
                    AppColor.primaryDark.opacity(0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            // Foreground content stays within the safe area, so the logo
            // and bell never sit under the notch/status bar.
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.sm)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(hero.eyebrow.uppercased())
                        .font(AppFont.eyebrow(11))
                        .tracking(2.4)
                        .foregroundStyle(AppColor.accentSoft)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.12)))

                    Text(hero.title)
                        .font(AppFont.title(24))
                        .foregroundStyle(AppColor.onDark)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(hero.subtitle)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColor.onDarkSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    searchBar
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.trailing, 12)
            }
        }
        .frame(height: 480)
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.textSecondary)

            TextField("", text: $searchText, prompt:
                Text(hero.searchPlaceholder).foregroundStyle(AppColor.textSecondary)
            )
            .font(AppFont.body(16))
            .foregroundStyle(AppColor.textPrimary)
            .submitLabel(.search)
            .onSubmit(onSeek)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onSeek) {
                Text(hero.searchActionLabel)
                    .font(AppFont.heading(14))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(AppColor.accent))
            }
            .buttonStyle(.plain)
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.leading, 12)
        .padding(.trailing, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColor.surface)
                .overlay(Capsule().stroke(AppColor.cardStroke, lineWidth: 1))
        )
    }

    private var promptChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(hero.prompts, id: \.self) { prompt in
                    Button { onPromptTap(prompt) } label: {
                        TagChip(text: prompt)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, AppSpacing.xs)
        }
    }
}
