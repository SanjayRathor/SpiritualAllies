//
//  RootView.swift
//  SpiritualAllies
//
//  Entry point for the public app experience.
//

import SwiftUI

struct RootView: View {
    let dependencies: AppDependencies
    var body: some View {
        MainTabView(dependencies: dependencies)
    }
}
