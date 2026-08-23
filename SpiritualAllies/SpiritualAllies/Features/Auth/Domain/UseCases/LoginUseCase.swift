//
//  LoginUseCase.swift
//  SpiritualAllies
//
//  Business action: authenticate the user (used for the silent login on splash).
//

import Foundation

protocol LoginUseCase: Sendable {
    @discardableResult
    func execute(username: String, password: String) async throws -> AuthSession
}

struct DefaultLoginUseCase: LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    @discardableResult
    func execute(username: String, password: String) async throws -> AuthSession {
        try await repository.login(username: username, password: password)
    }
}
