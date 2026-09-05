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
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 1, height: 56)
                                .offset(x: 8)
                        }
                    }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColor.primary)
                .shadow(color: AppColor.shadow.opacity(0.14), radius: 12, x: 0, y: 6)
        )
    }

    private func statCard(_ stat: HomeStat) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: systemImage(for: stat))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 16, height: 16, alignment: .center)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] - 2 }

                Text(displayValue(for: stat))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.accent)

                if isStarStat(stat) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(AppColor.accent)
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] - 5 }
                }
            }
            .frame(height: 20, alignment: .center)

            Text(stat.sub.isEmpty ? stat.label : stat.sub)
                .font(AppFont.body(10))
                .foregroundStyle(AppColor.onDarkSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .top)
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .center)
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
