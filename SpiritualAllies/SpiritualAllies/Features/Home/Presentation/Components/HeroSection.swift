//
//  HeroSection.swift
//  SpiritualAllies
//
//  Swipeable, auto-advancing hero carousel for the Home screen.
//

import SwiftUI
import UIKit

struct HeroSection: View {
    let slides: [HomeHero]
    @Binding var searchText: String
    var onSeek: () -> Void = {}
    var onPromptTap: (String) -> Void = { _ in }

    @State private var selectedIndex = 0

    private var topSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            heroCarousel
                .frame(height: 540)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            await autoAdvanceLoop()
        }
    }

    private var heroCarousel: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedIndex) {
                ForEach(slides.indices, id: \.self) { index in
                    heroCard(for: slides[index])
                        .tag(index)
                }
            }

            VStack(spacing: AppSpacing.sm) {
                // The seek bar stays fixed while the feature content changes.
                searchBar(placeholder: "What is your heart seeking?", actionLabel: "Seek")
                fixedTags
                pageIndicator
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            if let firstSlide = slides.first {
                header(for: firstSlide)
                    .padding(.horizontal, 20)
                    .padding(.top, topSafeAreaInset + 10)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.35), value: selectedIndex)
    }

    private func heroCard(for slide: HomeHero) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ZStack {
                    RemoteImage(path: slide.heroImagePath)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()

                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.08),
                            AppColor.primaryDark.opacity(0.05),
                            AppColor.primaryDark.opacity(0.34),
                            AppColor.primaryDark.opacity(0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .shadow(color: AppColor.shadow.opacity(0.18), radius: 24, x: 0, y: 14)

                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(slide.title)
                            .font(AppFont.title(28))
                            .foregroundStyle(AppColor.onDark)
                            .shadow(color: .black.opacity(0.75), radius: 5, x: 0, y: 2)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(slide.subtitle)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColor.onDarkSecondary)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)

                    }
                    .padding(.horizontal, 20)
                    // Reserve space for the fixed seek bar, tags, and page controls.
                    .padding(.bottom, 190)
                    .padding(.trailing, 12)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    /// Keeps the top row readable over every slide image.
    private func header(for slide: HomeHero) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(slide.brandMark.isEmpty ? "श्री" : slide.brandMark)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColor.accent)
                .frame(width: 38, height: 38)
                .background(Circle().fill(AppColor.primary.opacity(0.65)))
                .overlay(Circle().stroke(AppColor.accent.opacity(0.5), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(slide.brandName.isEmpty ? "SpiritualAllies" : slide.brandName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.onDark)
                    .shadow(color: .black.opacity(0.65), radius: 3, x: 0, y: 1)
                Text(slide.tagline.isEmpty ? "TRANSFORM · HEAL · AWAKEN" : slide.tagline.uppercased())
                    .font(AppFont.eyebrow(10))
                    .tracking(2.0)
                    .foregroundStyle(AppColor.onDarkSecondary)
                    .shadow(color: .black.opacity(0.65), radius: 3, x: 0, y: 1)
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

    private func searchBar(placeholder: String, actionLabel: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.textSecondary)

            TextField("", text: $searchText, prompt:
                Text(placeholder).foregroundStyle(AppColor.textSecondary)
            )
            .font(AppFont.body(16))
            .foregroundStyle(AppColor.textPrimary)
            .submitLabel(.search)
            .onSubmit(onSeek)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onSeek) {
                Text(actionLabel)
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

    private var fixedTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach([
                    "Healing After Burnout",
                    "Home Satyanarayan Puja",
                    "Find A Vipassana Guide",
                    "Kerala Ayurveda Retreat",
                    "Ganga Aarti For Family"
                ], id: \.self) { tag in
                    Button {
                        onPromptTap(tag)
                    } label: {
                        Text(tag)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColor.onDarkSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.black.opacity(0.24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(slides.indices, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == selectedIndex ? AppColor.accent : Color.white.opacity(0.4))
                    .frame(width: index == selectedIndex ? 20 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.25), value: selectedIndex)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.22))
                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }

    private func autoAdvanceLoop() async {
        guard slides.count > 1 else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                selectedIndex = (selectedIndex + 1) % slides.count
            }
        }
    }
}
