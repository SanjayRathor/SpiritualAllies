//
//  AppDependencies.swift
//  SpiritualAllies
//
//  Composition root. Single place where concrete implementations are wired to
//  their protocols. A shared token store + auth interceptor make every request
//  from `apiClient` automatically carry the Bearer token after login.
//

import Foundation

@MainActor
final class AppDependencies {
    /// Shared, in-memory token store consulted by the auth interceptor.
    private let tokenStore: TokenProviding = InMemoryTokenStore()

    /// One authenticated API client shared across features.
    private lazy var apiClient: APIClient = AlamofireAPIClient(
        interceptor: AuthInterceptor(tokenProvider: tokenStore)
    )

    // MARK: - Auth

    private func makeAuthRepository() -> AuthRepository {
        AuthRepositoryImpl(
            remoteDataSource: APIAuthRemoteDataSource(client: apiClient),
            tokenStore: tokenStore
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
