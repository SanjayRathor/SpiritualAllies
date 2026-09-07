//
//  MainTabView.swift
//  SpiritualAllies
//
//  Root tab bar: Home · Offering · Places · Mentors · Profile.
//

import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies
    @State private var isHomeLoading = true

    var body: some View {
        TabView {
            Tab("tab.home", systemImage: "house") {
                HomeView(
                    viewModel: dependencies.makeHomeViewModel(),
                    onLoadingStateChanged: { isLoading in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isHomeLoading = isLoading
                        }
                    }
                )
            }
            Tab("tab.offering", systemImage: "hands.sparkles") {
                OfferingView(viewModel: dependencies.makeOfferingViewModel())
            }
            Tab("tab.places", systemImage: "building.columns") {
                PlacesView(viewModel: dependencies.makePlacesViewModel())
            }
            Tab("tab.mentors", systemImage: "person.2") {
                MentorsView(viewModel: dependencies.makeMentorViewModel())
            }
            Tab("tab.profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
        }
        .tint(AppColor.primary)
        .toolbar(isHomeLoading ? .hidden : .visible, for: .tabBar)
    }
}
