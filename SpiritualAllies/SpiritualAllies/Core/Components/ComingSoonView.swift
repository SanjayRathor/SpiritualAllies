//
//  ComingSoonView.swift
//  SpiritualAllies
//
//  Lightweight placeholder for tabs that are not yet implemented.
//

import SwiftUI

struct ComingSoonView: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(AppColor.primary)
                Text(title)
                    .font(AppFont.heading(24))
                    .foregroundStyle(AppColor.textPrimary)
                Text("home.comingSoon")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}
