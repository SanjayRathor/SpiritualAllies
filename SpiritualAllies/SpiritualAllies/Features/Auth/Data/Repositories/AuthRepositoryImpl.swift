//
//  AuthRepositoryImpl.swift
//  SpiritualAllies
//
//  Performs login and persists the returned tokens into the token store so
//  subsequent requests are automatically authenticated by the interceptor.
//

import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let remoteDataSource: AuthRemoteDataSource
    private let tokenStore: TokenProviding

    init(remoteDataSource: AuthRemoteDataSource, tokenStore: TokenProviding) {
        self.remoteDataSource = remoteDataSource
        self.tokenStore = tokenStore
    }

    @discardableResult
    func login(username: String, password: String) async throws -> AuthSession {
        let dto = try await remoteDataSource.login(
            LoginRequestDTO(username: username, password: password)
        )
        let session = AuthDTOMapper.map(dto)
        tokenStore.update(accessToken: session.accessToken, refreshToken: session.refreshToken)
        return session
    }
}
