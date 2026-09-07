//
//  FetchOfferingsUseCase.swift
//  SpiritualAllies
//

import Foundation

protocol FetchOfferingsUseCase: Sendable {
    func execute(page: Int, size: Int) async throws -> OfferingSection
}

struct DefaultFetchOfferingsUseCase: FetchOfferingsUseCase {
    private let repository: OfferingRepository

    init(repository: OfferingRepository) {
        self.repository = repository
    }

    func execute(page: Int, size: Int) async throws -> OfferingSection {
        try await repository.fetchOfferings(page: page, size: size)
    }
}
