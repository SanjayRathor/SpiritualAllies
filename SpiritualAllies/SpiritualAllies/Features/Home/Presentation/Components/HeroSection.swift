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
    var onOpenSearch: () -> Void = {}
    var onOpenPanchang: () -> Void = {}

    @State private var selectedIndex = 0
    @State private var locationManager = LocationManager()
    @State private var selectedDate: Date?
    @State private var isDatePickerPresented = false

    private var dateLabel: String {
        guard let selectedDate else { return "Any date" }
        return selectedDate.formatted(.dateTime.day().month(.abbreviated))
    }

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
                .frame(height: 600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            await autoAdvanceLoop()
        }
        .task {
            await locationManager.resolveCountry()
        }
        .sheet(isPresented: $isDatePickerPresented) {
            datePickerSheet
        }
    }

    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                DatePicker(
                    "Date",
                    selection: Binding(
                        get: { selectedDate ?? Date() },
                        set: { selectedDate = $0 }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(AppColor.accent)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .background(AppColor.background)
            .navigationTitle("Choose a date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Any date") {
                        selectedDate = nil
                        isDatePickerPresented = false
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if selectedDate == nil { selectedDate = Date() }
                        isDatePickerPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.accent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var heroCarousel: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedIndex) {
                ForEach(slides.indices, id: \.self) { index in
                    heroCard(for: slides[index])
                        .tag(index)
                }
            }

            VStack(spacing: 12) {
                searchBar(placeholder: currentSlide?.searchPlaceholder ?? "Search temples, poojas, events...")
                pageIndicator
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            if let firstSlide = slides.first {
                header(for: firstSlide)
                    .padding(.horizontal, 20)
                    .padding(.top, topSafeAreaInset + 8)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.35), value: selectedIndex)
    }

    private var currentSlide: HomeHero? {
        slides.indices.contains(selectedIndex) ? slides[selectedIndex] : slides.first
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
                        stops: [
                            .init(color: AppColor.surface.opacity(0.96), location: 0.0),
                            .init(color: AppColor.surface.opacity(0.82), location: 0.25),
                            .init(color: AppColor.surface.opacity(0.55), location: 0.50),
                            .init(color: AppColor.surface.opacity(0.15), location: 0.68),
                            .init(color: Color.clear, location: 0.80),
                            .init(color: AppColor.primaryDark.opacity(0.12), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(slide.eyebrow.isEmpty ? "SACRED PLACES · RITUALS · GUIDANCE" : slide.eyebrow.uppercased())
                        .font(AppFont.eyebrow(10))
                        .tracking(2.4)
                        .foregroundStyle(AppColor.primary.opacity(0.85))
                        .padding(.horizontal, 20)

                    highlightedTitle(slide.title)
                        .font(.system(size: 31, weight: .semibold, design: .serif))
                        .tracking(-0.35)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: Color.white.opacity(0.45), radius: 1, y: 1)
                        .padding(.leading, 20)
                        .padding(.trailing, 40)

                    Text(slide.subtitle)
                        .font(.system(size: AppFontSize.body, weight: .regular, design: .rounded))
                        .foregroundStyle(AppColor.primary)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: Color.white.opacity(0.4), radius: 1, y: 1)
                        .padding(.leading, 20)
                        .padding(.trailing, 40)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            heroPill("12k+ temples", icon: "building.columns")
                            heroPill("Live poojas", icon: "dot.radiowaves.left.and.right")
                            heroPill("Verified guides", icon: "checkmark.shield")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 0)
                }
                .padding(.top, topSafeAreaInset + 86)
                .padding(.bottom, 160)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                .clipped()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    /// Renders the title in deep green with the final word in gold.
    private func highlightedTitle(_ title: String) -> Text {
        let words = title.split(separator: " ")
        guard let last = words.last, words.count > 1 else {
            return Text(title).foregroundStyle(AppColor.primary)
        }
        let head = words.dropLast().joined(separator: " ") + " "
        return Text(head).foregroundStyle(AppColor.primary)
            + Text(String(last)).foregroundStyle(AppColor.accent)
    }

    /// Keeps the top row readable over every slide image.
    private func header(for slide: HomeHero) -> some View {
        HStack(spacing: 10) {
            LotusMark()
                .stroke(AppColor.accent, style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
                .frame(width: 44, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(slide.brandName.isEmpty ? "SpiritualAllies" : slide.brandName)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(AppColor.primary)
                Text(slide.tagline.isEmpty ? "TRANSFORM HEAL AWAKEN" : slide.tagline.uppercased())
                    .font(AppFont.eyebrow(9))
                    .tracking(2.4)
                    .foregroundStyle(AppColor.primary.opacity(0.7))
            }

            Spacer(minLength: 8)

            Button(action: onOpenSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(AppColor.primary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(AppColor.primary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
    }

    private func searchBar(placeholder: String) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(AppColor.accent)

                TextField("", text: $searchText, prompt:
                    Text(placeholder).foregroundStyle(AppColor.textSecondary.opacity(0.8))
                )
                .font(AppFont.body())
                .foregroundStyle(AppColor.textPrimary)
                .submitLabel(.search)
                .onSubmit(onSeek)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .frame(height: 42)

            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button { isDatePickerPresented = true } label: {
                        searchFilter(icon: "calendar", title: dateLabel)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(AppColor.cardStroke)
                        .frame(width: 1, height: 24)

                    Button { Task { await locationManager.resolveCountry() } } label: {
                        searchFilter(
                            icon: "mappin.and.ellipse",
                            title: locationManager.displayCountry,
                            isLoading: locationManager.state == .requesting
                        )
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppColor.cardStroke, lineWidth: 1)
                        )
                )

                Button(action: onSeek) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(AppColor.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(.top, 2)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: AppColor.primaryDark.opacity(0.13), radius: 18, y: 9)
    }

    private func searchFilter(icon: String, title: String, isLoading: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColor.accent)
            Text(title)
                .font(.system(size: AppFontSize.bodySmall, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
            Spacer(minLength: 4)
            if isLoading {
                ProgressView()
                    .controlSize(.mini)
                    .tint(AppColor.textSecondary)
            } else {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .contentShape(Rectangle())
    }

    private func heroPill(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.accent)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.primary)
                .lineLimit(1)
        }
        .fixedSize()
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.94)))
        .overlay(Capsule().stroke(Color.white.opacity(0.75), lineWidth: 0.8))
        .shadow(color: AppColor.primaryDark.opacity(0.06), radius: 5, y: 2)
    }

    private var fixedTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(currentSlide?.prompts ?? [], id: \.self) { tag in
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

    @ViewBuilder
    private var pageIndicator: some View {
        if slides.count > 1 {
            HStack(spacing: 6) {
                ForEach(slides.indices, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(index == selectedIndex ? AppColor.accent : Color.white.opacity(0.6))
                        .frame(width: index == selectedIndex ? 18 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                }
            }
        }
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

/// Minimal line-art lotus used as the brand mark in the hero header.
private struct LotusMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let baseY = rect.minY + h * 0.92
        let cx = rect.midX

        func petal(tipX: CGFloat, tipY: CGFloat, spread: CGFloat) {
            path.move(to: CGPoint(x: cx, y: baseY))
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              control: CGPoint(x: cx - spread, y: baseY - h * 0.45))
            path.addQuadCurve(to: CGPoint(x: cx, y: baseY),
                              control: CGPoint(x: tipX + spread * 0.6, y: baseY - h * 0.45))
        }

        // Center petal.
        petal(tipX: cx, tipY: rect.minY + h * 0.05, spread: w * 0.14)
        // Inner side petals.
        petal(tipX: cx - w * 0.22, tipY: rect.minY + h * 0.18, spread: w * 0.18)
        petal(tipX: cx + w * 0.22, tipY: rect.minY + h * 0.18, spread: -w * 0.04)
        // Outer side petals.
        petal(tipX: cx - w * 0.42, tipY: rect.minY + h * 0.42, spread: w * 0.20)
        petal(tipX: cx + w * 0.42, tipY: rect.minY + h * 0.42, spread: -w * 0.08)

        // Base leaf curve.
        path.move(to: CGPoint(x: rect.minX + w * 0.08, y: baseY - h * 0.12))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - w * 0.08, y: baseY - h * 0.12),
                          control: CGPoint(x: cx, y: rect.maxY + h * 0.12))
        return path
    }
}
