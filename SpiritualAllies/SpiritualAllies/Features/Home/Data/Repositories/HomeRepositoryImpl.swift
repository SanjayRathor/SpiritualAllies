//
//  HomeRepositoryImpl.swift
//  SpiritualAllies
//
//  Concrete HomeRepository: pulls DTOs from a data source and maps them into
//  domain entities. It depends on the `HomeRemoteDataSource` protocol, so the
//  mock and real sources are interchangeable.
//

import Foundation

final class HomeRepositoryImpl: HomeRepository {
    private let remoteDataSource: HomeRemoteDataSource

    init(remoteDataSource: HomeRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchDashboard() async throws -> HomeDashboard {
        let dto = try await remoteDataSource.fetchDashboard()
        return HomeDTOMapper.map(dto)
    }
}
