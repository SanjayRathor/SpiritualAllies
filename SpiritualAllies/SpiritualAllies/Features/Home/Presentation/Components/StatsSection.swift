//
//  StatsSection.swift
//  SpiritualAllies
//
//  Analytics bar (guides / places / offerings / rating).
//

import SwiftUI

struct StatsSection: View {
    let stats: [HomeStat]

    var body: some View {
        bar
            .padding(.horizontal, 15)
    }

    private var bar: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.prefix(4).enumerated()), id: \.element.id) { index, stat in
                statCard(stat)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        if index < min(stats.count, 4) - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: 1, height: 64)
                        }
                    }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.primary)
                .shadow(color: AppColor.shadow.opacity(0.14), radius: 12, x: 0, y: 6)
        )
    }

    private func statCard(_ stat: HomeStat) -> some View {
        VStack(spacing: 7) {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: systemImage(for: stat))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 18, height: 18, alignment: .center)

                Text(displayValue(for: stat))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.accent)

            }
            .frame(height: 25, alignment: .center)

            Text(stat.sub.isEmpty ? stat.label : stat.sub)
                .font(AppFont.body(13))
                .foregroundStyle(AppColor.onDarkSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 30, alignment: .top)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .center)
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

    private func systemImage(for stat: HomeStat) -> String {
        switch stat.icon.lowercased() {
        case "mentors", "users": return "person.2"
        case "globe": return "globe"
        case "star": return "star"
        default: return "chart.bar"
        }
    }
}
