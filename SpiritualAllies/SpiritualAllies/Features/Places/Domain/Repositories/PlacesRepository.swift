//
//  PlacesRepository.swift
//  SpiritualAllies
//
//  Domain-facing contract for the Places tab.
//

import Foundation

protocol PlacesRepository: Sendable {
    func fetchPlaces(page: Int, size: Int) async throws -> SacredPlacePage
}
