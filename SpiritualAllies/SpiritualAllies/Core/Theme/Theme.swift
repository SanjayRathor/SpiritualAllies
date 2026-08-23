//
//  Theme.swift
//  SpiritualAllies
//
//  Centralized design tokens (colors, spacing, typography, radii) so the UI
//  stays consistent and easy to restyle from a single place.
//

import SwiftUI

extension Color {
    /// Creates a color from a 24-bit hex value, e.g. 0xF4EFE4.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum AppColor {
    /// Warm cream page background.
    static let background = Color(hex: 0xF4EFE3)
    /// Soft elevated surface used by redesigned cards.
    static let surface = Color(hex: 0xFFFDF8)
    /// Slightly warmer surface for layered sections.
    static let surfaceAlt = Color(hex: 0xF9F4EA)
    /// Deep temple green used for the hero and cards.
    static let primary = Color(hex: 0x1E3A2B)
    static let primaryDark = Color(hex: 0x14261D)
    /// Gold accent for CTAs and highlights.
    static let accent = Color(hex: 0xCBA135)
    static let accentSoft = Color(hex: 0xF1E0AA)
    static let textPrimary = Color(hex: 0x23271F)
    static let textSecondary = Color(hex: 0x6B6F62)
    static let onDark = Color.white
    static let onDarkSecondary = Color.white.opacity(0.78)
    static let cardStroke = Color.black.opacity(0.06)
    static let shadow = Color.black.opacity(0.12)
}

/// Plural alias kept for call sites that reference `AppColors`.
typealias AppColors = AppColor

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
}

enum AppFont {
    static func title(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func heading(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .semibold) }
    static func body(_ size: CGFloat = 15) -> Font { .system(size: size, weight: .regular) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .medium) }
    static func eyebrow(_ size: CGFloat = 11) -> Font { .system(size: size, weight: .semibold) }
}
