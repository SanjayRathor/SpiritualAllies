//
//  FetchSacredPlacesUseCase.swift
//  SpiritualAllies
//
//  Encapsulates paged loading for the Places tab.
//

import Foundation

protocol FetchSacredPlacesUseCase: Sendable {
    func execute(page: Int, size: Int) async throws -> SacredPlacePage
}

struct DefaultFetchSacredPlacesUseCase: FetchSacredPlacesUseCase {
    private let repository: PlacesRepository

    init(repository: PlacesRepository) {
        self.repository = repository
    }

    func execute(page: Int, size: Int) async throws -> SacredPlacePage {
        try await repository.fetchPlaces(page: page, size: size)
    }
}
