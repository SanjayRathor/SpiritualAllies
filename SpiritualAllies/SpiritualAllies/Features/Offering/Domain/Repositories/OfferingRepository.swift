//
//  OfferingRepository.swift
//  SpiritualAllies
//

import Foundation

protocol OfferingRepository: Sendable {
    func fetchOfferings(page: Int, size: Int) async throws -> OfferingSection
}
