//
//  PlacesRepositoryImpl.swift
//  SpiritualAllies
//
//  Concrete PlacesRepository: fetches paged data and maps it to domain types.
//

import Foundation

final class PlacesRepositoryImpl: PlacesRepository {
    private let remoteDataSource: PlacesRemoteDataSource

    init(remoteDataSource: PlacesRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchPlaces(page: Int, size: Int) async throws -> SacredPlacePage {
        let dto = try await remoteDataSource.fetchPlaces(page: page, size: size)
        return PlacesDTOMapper.map(dto)
    }
}
