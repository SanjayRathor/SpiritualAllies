//
//  AppDependencies.swift
//  SpiritualAllies
//
//  Composition root. Single place where concrete implementations are wired to
//  their protocols.
//

import Foundation

@MainActor
final class AppDependencies {
    /// Public API client shared across features.
    private lazy var apiClient: APIClient = AlamofireAPIClient()

    // MARK: - Auth

    private func makeAuthRepository() -> AuthRepository {
        AuthRepositoryImpl(
            remoteDataSource: APIAuthRemoteDataSource(client: apiClient),
            tokenStore: InMemoryTokenStore()
        )
    }

    func makeSplashViewModel() -> SplashViewModel {
        return SplashViewModel()
    }

    // MARK: - Home

    private func makeHomeRemoteDataSource() -> HomeRemoteDataSource {
        APIHomeRemoteDataSource(client: apiClient)
    }

    private func makeHomeRepository() -> HomeRepository {
        HomeRepositoryImpl(remoteDataSource: makeHomeRemoteDataSource())
    }

    func makeHomeViewModel() -> HomeViewModel {
        let useCase = DefaultFetchHomeDashboardUseCase(repository: makeHomeRepository())
        return HomeViewModel(fetchDashboard: useCase)
    }

    // MARK: - Places

    private func makePlacesRemoteDataSource() -> PlacesRemoteDataSource {
        APIPlacesRemoteDataSource(client: apiClient)
    }

    private func makePlacesRepository() -> PlacesRepository {
        PlacesRepositoryImpl(remoteDataSource: makePlacesRemoteDataSource())
    }

    func makePlacesViewModel() -> PlacesViewModel {
        let useCase = DefaultFetchSacredPlacesUseCase(repository: makePlacesRepository())
        return PlacesViewModel(fetchPlaces: useCase)
    }

    // MARK: - Offering

    private func makeOfferingRemoteDataSource() -> OfferingRemoteDataSource {
        APIOfferingRemoteDataSource(client: apiClient)
    }

    private func makeOfferingRepository() -> OfferingRepository {
        OfferingRepositoryImpl(remoteDataSource: makeOfferingRemoteDataSource())
    }

    func makeOfferingViewModel() -> OfferingViewModel {
        let useCase = DefaultFetchOfferingsUseCase(repository: makeOfferingRepository())
        return OfferingViewModel(fetchOfferings: useCase)
    }

    // MARK: - Mentors

    private func makeMentorRemoteDataSource() -> MentorRemoteDataSource {
        APIMentorRemoteDataSource(client: apiClient)
    }

    private func makeMentorRepository() -> MentorRepository {
        MentorRepositoryImpl(remoteDataSource: makeMentorRemoteDataSource())
    }

    func makeMentorViewModel() -> MentorViewModel {
        let useCase = DefaultFetchMentorsUseCase(repository: makeMentorRepository())
        return MentorViewModel(fetchMentors: useCase)
    }
}
