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

protocol FetchOfferingDetailUseCase: Sendable {
    func execute(id: String) async throws -> OfferingDetail
}

struct DefaultFetchOfferingDetailUseCase: FetchOfferingDetailUseCase {
    private let repository: OfferingRepository

    init(repository: OfferingRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> OfferingDetail {
        try await repository.fetchOfferingDetail(id: id)
    }
}
