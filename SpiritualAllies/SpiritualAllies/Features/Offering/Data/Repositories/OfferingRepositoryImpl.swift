//
//  OfferingRepositoryImpl.swift
//  SpiritualAllies
//

import Foundation

final class OfferingRepositoryImpl: OfferingRepository {
    private let remoteDataSource: OfferingRemoteDataSource

    init(remoteDataSource: OfferingRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchOfferings(page: Int, size: Int) async throws -> OfferingSection {
        OfferingDTOMapper.map(try await remoteDataSource.fetchOfferings(page: page, size: size))
    }
}
