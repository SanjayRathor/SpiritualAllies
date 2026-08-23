//
//  SpiritualAlliesApp.swift
//  SpiritualAllies
//
//  Created by sanjay.rathor1 on 22/08/26.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct SpiritualAlliesApp: App {
    /// Composition root built once for the app lifetime.
    @State private var dependencies = AppDependencies()

    init() {
        configureKeyboardManager()
    }

    /// Global keyboard-avoidance setup (runs once at launch).
    private func configureKeyboardManager() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 20
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
