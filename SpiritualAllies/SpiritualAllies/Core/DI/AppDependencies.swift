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
        let useCase = DefaultLoginUseCase(repository: makeAuthRepository())
        return SplashViewModel(login: useCase)
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
}
