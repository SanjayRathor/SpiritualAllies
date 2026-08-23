//
//  HomeRepository.swift
//  SpiritualAllies
//
//  Domain-facing contract for fetching Home data. Implementations live in the
//  Data layer; the Domain/Presentation layers depend only on this protocol
//  (Dependency Inversion Principle).
//

import Foundation

protocol HomeRepository: Sendable {
    func fetchDashboard() async throws -> HomeDashboard
}
