//
//  HomeRemoteDataSource.swift
//  SpiritualAllies
//
//  Abstraction over the source of Home DTOs. Swapping between the mock and the
//  real API is a one-line change in the composition root — no other code moves.
//

import Foundation

protocol HomeRemoteDataSource: Sendable {
    func fetchDashboard() async throws -> HomeResponseDTO
}
