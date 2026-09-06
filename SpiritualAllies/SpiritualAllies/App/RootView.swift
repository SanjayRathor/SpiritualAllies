//
//  RootView.swift
//  SpiritualAllies
//
//  Entry point for the public app experience.
//

import SwiftUI

struct RootView: View {
    let dependencies: AppDependencies
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(
                    viewModel: dependencies.makeSplashViewModel(),
                    onReady: {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showSplash = false
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(1)
            } else {
                MainTabView(dependencies: dependencies)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
    }
}
