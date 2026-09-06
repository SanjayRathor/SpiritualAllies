//
//  SplashViewModel.swift
//  SpiritualAllies
//
//  Performs the silent login while the splash screen is shown, then signals
//  when the app is ready to move to the main experience.
//

import Foundation
import Observation

@MainActor
@Observable
final class SplashViewModel {
    enum State: Equatable {
        case authenticating
        case ready
        case failed(String)
    }

    private(set) var state: State = .authenticating

    /// Minimum time to keep the splash visible for brand presence.
    private let minimumDisplay: Duration

    init(minimumDisplay: Duration = .seconds(1.2)) {
        self.minimumDisplay = minimumDisplay
    }

    func start() async {
        state = .authenticating

        // Keep the splash visible for a minimum duration for brand presence.
        try? await Task.sleep(for: minimumDisplay)

        // Skip login API call and mark as ready directly
        state = .ready
    }
}
