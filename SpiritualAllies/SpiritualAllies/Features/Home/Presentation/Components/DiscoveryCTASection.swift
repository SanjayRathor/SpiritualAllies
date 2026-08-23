//
//  DiscoveryCTASection.swift
//  SpiritualAllies
//
//  "AI guided discovery" call-to-action band with a gold button.
//

import SwiftUI

struct DiscoveryCTASection: View {
    let cta: HomeDiscoveryCTA
    var onTap: () -> Void = {}

    var body: some View {
        SectionSurface {
            ZStack {
                GeometryReader { proxy in
                    RemoteImage(path: cta.backgroundImagePath)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }

                LinearGradient(
                    colors: [
                        AppColor.primaryDark.opacity(0.84),
                        AppColor.primary.opacity(0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(cta.eyebrow.uppercased())
                        .font(AppFont.eyebrow(11))
                        .tracking(2)
                        .foregroundStyle(AppColor.accentSoft)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.12)))

                    Text(cta.title)
                        .font(AppFont.heading(24))
                        .foregroundStyle(AppColor.onDark)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(cta.subtitle)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColor.onDarkSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(action: onTap) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "sparkles")
                            Text(cta.ctaLabel)
                        }
                        .font(AppFont.caption(15))
                        .foregroundStyle(AppColor.primaryDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(Capsule().fill(AppColor.accent))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 240, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: AppColor.shadow.opacity(0.18), radius: 24, x: 0, y: 14)
        }
    }
}
