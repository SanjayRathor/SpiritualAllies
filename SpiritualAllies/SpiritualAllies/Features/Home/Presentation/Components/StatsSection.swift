//
//  StatsSection.swift
//  SpiritualAllies
//
//  Horizontal green stats bar (Places / Offerings / Guides / Rating).
//

import SwiftUI

struct StatsSection: View {
    let stats: [HomeStat]

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        SectionSurface {
            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(stats) { stat in
                    statCard(stat)
                }
            }
        }
    }

    private func statCard(_ stat: HomeStat) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: stat.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.primaryDark)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(AppColor.accentSoft))
                Spacer()
            }

            Text(stat.value)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)

            Text(stat.label)
                .font(AppFont.caption(13))
                .foregroundStyle(AppColor.textPrimary)

            Text(stat.sub)
                .font(AppFont.eyebrow(10))
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColor.surfaceAlt)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppColor.cardStroke, lineWidth: 1)
                )
        )
    }
}
