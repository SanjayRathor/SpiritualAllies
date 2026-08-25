//
//  MainTabView.swift
//  SpiritualAllies
//
//  Root tab bar: Home · Offering · Places · Mentors · Profile.
//

import SwiftUI

struct MainTabView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab("tab.home", systemImage: "house") {
                HomeView(viewModel: dependencies.makeHomeViewModel())
            }
            Tab("tab.offering", systemImage: "hands.sparkles") {
                OfferingView()
            }
            Tab("tab.places", systemImage: "building.columns") {
                PlacesView(viewModel: dependencies.makePlacesViewModel())
            }
            Tab("tab.mentors", systemImage: "person.2") {
                MentorsView()
            }
            Tab("tab.profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
        }
        .tint(AppColor.primary)
    }
}
