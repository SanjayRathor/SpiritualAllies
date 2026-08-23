//
//  DiscoveryCTASection.swift
//  SpiritualAllies
//
//  AI-guided discovery CTA card.
//

import SwiftUI

struct DiscoveryCTASection: View {
    let cta: HomeDiscoveryCTA
    var onTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(AppColor.primary)

                Circle()
                    .stroke(AppColor.accent.opacity(0.10), lineWidth: 12)
                    .frame(width: 126, height: 126)
                    .offset(x: 38, y: -24)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(AppColor.accent.opacity(0.10))
                    .rotationEffect(.degrees(38))
                    .offset(x: -18, y: 6)

                VStack(alignment: .leading, spacing: 11) {
                    Text(cta.eyebrow.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(3.6)
                        .foregroundStyle(AppColor.accentSoft)

                    Text(cta.title)
                        .font(.system(size: 27, weight: .bold, design: .serif))
                        .foregroundStyle(AppColor.onDark)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(cta.subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColor.onDarkSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 28)

                    Button(action: onTap) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15, weight: .semibold))
                            Text(cta.ctaLabel)
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(AppColor.primaryDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(AppColor.accent))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 230, alignment: .leading)
            .padding(.horizontal, AppSpacing.lg)
            .shadow(color: AppColor.shadow.opacity(0.18), radius: 18, x: 0, y: 10)
        }
    }
}
