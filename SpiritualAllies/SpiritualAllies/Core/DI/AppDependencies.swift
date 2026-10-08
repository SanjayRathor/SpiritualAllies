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

    func makeSearchViewModel(initialQuery: String) -> SearchViewModel {
        let dataSource = APISearchRemoteDataSource(client: apiClient)
        let repository = SearchRepositoryImpl(remoteDataSource: dataSource)
        let useCase = DefaultSearchSpiritualContentUseCase(repository: repository)
        return SearchViewModel(initialQuery: initialQuery, searchContent: useCase)
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

    func makeOfferingDetailViewModel(offeringID: String) -> OfferingDetailViewModel {
        let useCase = DefaultFetchOfferingDetailUseCase(repository: makeOfferingRepository())
        return OfferingDetailViewModel(offeringID: offeringID, fetchDetail: useCase)
    }

    // MARK: - Mentors

    private func makeMentorRemoteDataSource() -> MentorRemoteDataSource {
        APIMentorRemoteDataSource(client: apiClient)
    }

    private func makeMentorRepository() -> MentorRepository {
        MentorRepositoryImpl(remoteDataSource: makeMentorRemoteDataSource())
    }

    func makeMentorViewModel() -> MentorViewModel {
        let repository = makeMentorRepository()
        return MentorViewModel(
            fetchMentors: DefaultFetchMentorsUseCase(repository: repository),
            fetchPage: DefaultFetchMentorPageUseCase(repository: repository)
        )
    }

    func makeMentorDetailViewModel(mentorID: String) -> MentorDetailViewModel {
        let useCase = DefaultFetchMentorDetailUseCase(repository: makeMentorRepository())
        return MentorDetailViewModel(mentorID: mentorID, fetchDetail: useCase)
    }
}
