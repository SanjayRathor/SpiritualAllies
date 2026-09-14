import SwiftUI

struct PanchangView: View {
    let panchang: HomePanchang?
    @State private var selectedSection: PanchangSection = .today

    private enum PanchangSection: String, CaseIterable, Identifiable {
        case today = "Today's Panchang"
        case tithi = "Tithi & Nakshatra"
        case muhurat = "Shubh Muhurat"
        case rahu = "Rahu Kaal"
        case festivals = "Festivals & Vrat"
        case calendar = "Festival Calendar"
        case ekadashi = "Ekadashi"
        case upcoming = "Upcoming Vrat"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .today, .calendar, .upcoming: return "calendar"
            case .tithi, .ekadashi: return "moon"
            case .muhurat: return "sparkles"
            case .rahu: return "clock"
            case .festivals: return "sun.max"
            }
        }
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    sectionPicker
                    sectionContent
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Panchang")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PanchangSection.allCases) { section in
                    Button { selectedSection = section } label: {
                        Label(section.rawValue, systemImage: section.icon)
                            .font(AppFont.heading(14))
                            .foregroundStyle(selectedSection == section ? AppColor.onDark : AppColor.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(Capsule().fill(selectedSection == section ? AppColor.primary : AppColor.surface))
                            .overlay(Capsule().stroke(AppColor.cardStroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .today: todayContent
        case .tithi: tithiContent
        case .muhurat: timingCard(title: "Shubh Muhurat", subtitle: "Auspicious windows for prayer, seva, and meaningful beginnings.", icon: "sparkles")
        case .rahu: timingCard(title: "Rahu Kaal", subtitle: "Plan important activities outside this window when possible.", icon: "clock")
        case .festivals: emptySection(title: "Festivals & Vrat", subtitle: "Festivals and vrat observances for your city will appear here.", icon: "sun.max")
        case .calendar: emptySection(title: "Festival Calendar", subtitle: "Explore upcoming festivals and sacred dates throughout the year.", icon: "calendar")
        case .ekadashi: emptySection(title: "Ekadashi", subtitle: "Ekadashi dates, timings, and definitions will appear here.", icon: "moon")
        case .upcoming: emptySection(title: "Upcoming Vrat", subtitle: "Your next vrat observances will appear here.", icon: "calendar.badge.clock")
        }
    }

    private var todayContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            daySummary
            if let panchang, !panchang.pillars.isEmpty { limbs(panchang.pillars) }
        }
    }

    private var tithiContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            detailCard(title: "Tithi & Nakshatra", subtitle: "The lunar day and star governing today's spiritual rhythm.", icon: "moon.stars.fill")
            if let panchang, !panchang.pillars.isEmpty { limbs(panchang.pillars) }
            detailCard(title: "About Tithi & Nakshatra", subtitle: "A tithi is a lunar day. A nakshatra is one of 27 segments along the Moon's path, each carrying its own spiritual qualities.", icon: "book.closed")
        }
    }

    private func timingCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon).font(AppFont.title(25)).foregroundStyle(AppColor.textPrimary)
            Text(subtitle).font(AppFont.body(16)).foregroundStyle(AppColor.textSecondary)
            VStack(spacing: 0) {
                timingRow("Brahma Muhurta", "04:28 AM - 06:04 AM")
                timingRow("Abhijit Muhurat", "11:47 AM - 12:36 PM", accent: true)
                timingRow("Godhuli Muhurat", "06:05 PM - 06:35 PM")
            }
        }
        .padding(22)
        .background(cardBackground())
    }

    private func timingRow(_ title: String, _ time: String, accent: Bool = false) -> some View {
        HStack {
            Text(title).font(AppFont.body(16)).foregroundStyle(accent ? AppColor.primary : AppColor.textPrimary)
            Spacer()
            Text(time).font(AppFont.body(14)).foregroundStyle(accent ? AppColor.primary : AppColor.textSecondary)
        }
        .padding(.vertical, 15)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func detailCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(AppFont.title(25)).foregroundStyle(AppColor.textPrimary)
            Text(subtitle).font(AppFont.body(16)).foregroundStyle(AppColor.textSecondary).lineSpacing(4)
        }
        .padding(22)
        .background(cardBackground())
    }

    private func emptySection(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 28)).foregroundStyle(AppColor.primary)
            Text(title).font(AppFont.title(25)).foregroundStyle(AppColor.textPrimary)
            Text(subtitle).font(AppFont.body(16)).foregroundStyle(AppColor.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(34)
        .background(cardBackground())
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DIVINE TIMING")
                .font(AppFont.eyebrow(11))
                .tracking(3)
                .foregroundStyle(AppColor.accent)
            Text("Today's Panchang")
                .font(AppFont.title(32))
                .foregroundStyle(AppColor.textPrimary)
            Text(panchang?.subtitle ?? "Tithi, nakshatra, muhurats, and auspicious timings for your day.")
                .font(AppFont.body(17))
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground())
    }

    private var daySummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Day Summary").font(AppFont.title(24)).foregroundStyle(AppColor.textPrimary)
            Label("Auspicious", systemImage: "checkmark")
                .font(AppFont.heading(15))
                .foregroundStyle(AppColor.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Capsule().fill(AppColor.primary.opacity(0.09)))
            VStack(alignment: .leading, spacing: 14) {
                summaryRow("Puja & archana")
                summaryRow("Meditation")
                summaryRow("Charity & seva")
            }
        }
        .padding(22)
        .background(cardBackground())
    }

    private func limbs(_ pillars: [HomePanchangPillar]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today's details").font(AppFont.title(24)).foregroundStyle(AppColor.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(pillars) { pillar in
                    VStack(alignment: .leading, spacing: 7) {
                        Text(pillar.label.uppercased()).font(AppFont.eyebrow(10)).tracking(1).foregroundStyle(AppColor.textSecondary)
                        Text(pillar.name).font(AppFont.heading(16)).foregroundStyle(AppColor.textPrimary)
                        if !pillar.detail.isEmpty { Text(pillar.detail).font(AppFont.body(13)).foregroundStyle(AppColor.textSecondary).lineLimit(2) }
                    }
                    .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 18).fill(AppColor.surface))
                }
            }
        }
        .padding(22)
        .background(cardBackground())
    }

    private var comingSoon: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("More Panchang details", systemImage: "sparkles")
                .font(AppFont.heading(18)).foregroundStyle(AppColor.primary)
            Text("Muhurat, Rahu Kaal, festivals, and Ekadashi will appear here as their dedicated data sections are connected.")
                .font(AppFont.body(15)).foregroundStyle(AppColor.textSecondary)
        }
        .padding(22)
        .background(cardBackground())
    }

    private func summaryRow(_ title: String) -> some View {
        Label(title, systemImage: "star.fill")
            .font(AppFont.body(16))
            .foregroundStyle(AppColor.textPrimary)
    }

    private func cardBackground() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(AppColor.surface)
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(AppColor.cardStroke, lineWidth: 1))
            .shadow(color: AppColor.shadow.opacity(0.1), radius: 10, y: 5)
    }
}
