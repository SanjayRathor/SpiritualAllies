//
//  StatsSection.swift
//  SpiritualAllies
//
//  Horizontal green stats bar (Places / Offerings / Guides / Rating).
//

import SwiftUI

struct StatsSection: View {
    let stats: [HomeStat]

    var body: some View {
        bar
            .padding(.horizontal, AppSpacing.lg)
    }

    private var bar: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.prefix(4).enumerated()), id: \.element.id) { index, stat in
                statCard(stat)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        if index < min(stats.count, 4) - 1 {
                            Capsule()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 1, height: 58)
                                .offset(x: 8)
                        }
                    }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(AppColor.primary)
        )
    }

    private func statCard(_ stat: HomeStat) -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 4) {
                Text(displayValue(for: stat))
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.accent)

                if isStarStat(stat) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColor.accent)
                        .offset(y: -1)
                }
            }

            Text(stat.label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.onDarkSecondary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .center)
    }

    private func isStarStat(_ stat: HomeStat) -> Bool {
        stat.icon.contains("star") || stat.label.lowercased() == "rating"
    }

    private func displayValue(for stat: HomeStat) -> String {
        guard isStarStat(stat) else { return stat.value }

        return stat.value
            .replacingOccurrences(of: "★", with: "")
            .replacingOccurrences(of: "*", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
