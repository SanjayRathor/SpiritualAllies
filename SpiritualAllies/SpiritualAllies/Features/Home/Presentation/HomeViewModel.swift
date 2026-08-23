//
//  HomeViewModel.swift
//  SpiritualAllies
//
//  Presentation logic for the Home screen. Depends only on the use-case
//  abstraction and exposes a simple, testable view state.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(HomeDashboard)
        case failed(String)
    }

    private(set) var state: ViewState = .idle
    /// Bound to the hero search field.
    var searchText: String = ""

    private let fetchDashboard: FetchHomeDashboardUseCase

    init(fetchDashboard: FetchHomeDashboardUseCase) {
        self.fetchDashboard = fetchDashboard
    }

    func onAppear() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        // Guard on connectivity first (NetworkMonitor via ToastHelper).
        guard ToastHelper.requireNetwork() else {
            state = .failed(AppStrings.Error.noInternet)
            return
        }

        state = .loading
        ToastHelper.showLoading(with: "Loading home")
        do {
            let dashboard = try await fetchDashboard.execute()
            ToastHelper.hideLoading()
            state = .loaded(dashboard)
        } catch {
            ToastHelper.hideLoading()
            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            state = .failed(message)
            ToastHelper.toast(message)
        }
    }
}
