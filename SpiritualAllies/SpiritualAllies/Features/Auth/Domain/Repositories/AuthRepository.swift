//
//  AuthRepository.swift
//  SpiritualAllies
//
//  Contract for authentication. The implementation is also responsible for
//  persisting the returned tokens into the token store.
//

import Foundation

protocol AuthRepository: Sendable {
    @discardableResult
    func login(username: String, password: String) async throws -> AuthSession
}
