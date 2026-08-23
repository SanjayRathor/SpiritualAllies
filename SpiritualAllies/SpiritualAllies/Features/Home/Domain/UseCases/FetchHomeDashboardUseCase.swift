//
//  FetchHomeDashboardUseCase.swift
//  SpiritualAllies
//
//  Encapsulates the single business action of loading the Home dashboard.
//  Keeping it as a use case (Single Responsibility) makes the intent explicit
//  and gives us a seam for future business rules (caching policy, filtering).
//

import Foundation

protocol FetchHomeDashboardUseCase: Sendable {
    func execute() async throws -> HomeDashboard
}

struct DefaultFetchHomeDashboardUseCase: FetchHomeDashboardUseCase {
    private let repository: HomeRepository

    init(repository: HomeRepository) {
        self.repository = repository
    }

    func execute() async throws -> HomeDashboard {
        try await repository.fetchDashboard()
    }
}
