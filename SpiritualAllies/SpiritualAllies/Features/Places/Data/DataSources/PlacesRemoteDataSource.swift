//
//  PlacesRemoteDataSource.swift
//  SpiritualAllies
//
//  Remote contract for paged sacred places.
//

import Foundation

protocol PlacesRemoteDataSource {
    func fetchPlaces(page: Int, size: Int) async throws -> SacredPlacesPageDTO
}
