//
//  RootView.swift
//  SpiritualAllies
//
//  Drives the app-launch flow: show the splash (which performs a silent login),
//  then transition to the main tabs once authentication succeeds.
//

import SwiftUI

struct RootView: View {
    let dependencies: AppDependencies
    @State private var isReady = false

    var body: some View {
        Group {
            if isReady {
                MainTabView(dependencies: dependencies)
                    .transition(.opacity)
            } else {
                SplashView(viewModel: dependencies.makeSplashViewModel()) {
                    withAnimation(.easeInOut(duration: 0.4)) { isReady = true }
                }
                .transition(.opacity)
            }
        }
    }
}
