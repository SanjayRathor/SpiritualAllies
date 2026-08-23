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

    private let login: LoginUseCase
    private let credentials: (username: String, password: String)
    /// Minimum time to keep the splash visible for brand presence.
    private let minimumDisplay: Duration

    init(
        login: LoginUseCase,
        credentials: (username: String, password: String) = ("admin", "admin"),
        minimumDisplay: Duration = .seconds(1.2)
    ) {
        self.login = login
        self.credentials = credentials
        self.minimumDisplay = minimumDisplay
    }

    func start() async {
        state = .authenticating

        // Keep the splash visible for a minimum duration regardless of outcome.
        async let delay: Void? = try? await Task.sleep(for: minimumDisplay)

        // Guard on connectivity first (NetworkMonitor via ToastHelper).
        guard ToastHelper.requireNetwork() else {
            _ = await delay
            state = .failed(AppStrings.Error.noInternet)
            return
        }

        ToastHelper.showLoading()
        do {
            try await login.execute(username: credentials.username, password: credentials.password)
            _ = await delay
            ToastHelper.hideLoading()
            state = .ready
        } catch {
            _ = await delay
            ToastHelper.hideLoading()
            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            state = .failed(message)
            ToastHelper.toast(message)
        }
    }
}
