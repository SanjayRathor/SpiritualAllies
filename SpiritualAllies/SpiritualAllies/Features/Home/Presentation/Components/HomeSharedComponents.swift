//
//  HomeSharedComponents.swift
//  SpiritualAllies
//
//  Small reusable views shared across Home sections.
//

import SwiftUI

/// Shared elevated section container used across the redesigned home screen.
struct SectionSurface<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(AppColor.cardStroke, lineWidth: 1)
                    )
                    .shadow(color: AppColor.shadow.opacity(0.12), radius: 24, x: 0, y: 14)
            )
            .padding(.horizontal, AppSpacing.lg)
    }
}

/// A rounded suggestion / tag chip.
struct TagChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppColor.primaryDark.opacity(0.92))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(Color.white)
            )
            .overlay(
                Capsule().stroke(AppColor.cardStroke.opacity(0.8), lineWidth: 1)
            )
    }
}

/// "Verified" pill used on catalog cards.
struct VerifiedBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
            Text("Verified")
        }
        .font(AppFont.eyebrow(10))
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppColor.primary.opacity(0.9)))
    }
}

/// Star + rating value.
struct RatingLabel: View {
    let rating: Double
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").foregroundStyle(AppColor.accent)
            Text(String(format: "%.1f", rating)).foregroundStyle(AppColor.textPrimary)
        }
        .font(AppFont.caption(12))
    }
}

/// Section header with a title and optional trailing "see all" action.
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFont.heading(24))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(AppFont.caption(14))
                    .foregroundStyle(AppColor.primaryDark)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Capsule().fill(AppColor.accentSoft))
            }
        }
    }
}
