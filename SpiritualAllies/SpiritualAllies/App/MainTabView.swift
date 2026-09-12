//
//  MainTabView.swift
//  SpiritualAllies
//
//  Root tab bar: Home · Offering · Places · Mentors · Profile.
//

import SwiftUI

enum AppTab: Hashable {
    case home, offering, places, mentors, profile
}

struct MainTabView: View {
    let dependencies: AppDependencies
    @State private var isHomeLoading = true
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("tab.home", systemImage: "house", value: .home) {
                HomeView(
                    viewModel: dependencies.makeHomeViewModel(),
                    onSelectTab: { selectedTab = $0 },
                    onLoadingStateChanged: { isLoading in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isHomeLoading = isLoading
                        }
                    }
                )
            }
            Tab("tab.offering", systemImage: "hands.sparkles", value: .offering) {
                OfferingView(viewModel: dependencies.makeOfferingViewModel())
            }
            Tab("tab.places", systemImage: "building.columns", value: .places) {
                PlacesView(viewModel: dependencies.makePlacesViewModel())
            }
            Tab("tab.mentors", systemImage: "person.2", value: .mentors) {
                MentorsView(
                    viewModel: dependencies.makeMentorViewModel(),
                    makeDetailViewModel: { mentorID in dependencies.makeMentorDetailViewModel(mentorID: mentorID) }
                )
            }
            Tab("tab.profile", systemImage: "person.crop.circle", value: .profile) {
                ProfileView()
            }
        }
        .tint(AppColor.primary)
        .toolbar(isHomeLoading ? .hidden : .visible, for: .tabBar)
    }
}
