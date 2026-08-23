//
//  AuthRemoteDataSource.swift
//  SpiritualAllies
//
//  Source of auth DTOs. Real (API) and mock implementations are interchangeable.
//

import Foundation

protocol AuthRemoteDataSource: Sendable {
    func login(_ request: LoginRequestDTO) async throws -> LoginResponseDTO
}

/// Network-backed auth data source hitting POST /auth/login.
final class APIAuthRemoteDataSource: AuthRemoteDataSource {
    private let client: APIClient
    private let path: String

    init(client: APIClient, path: String = "auth/login") {
        self.client = client
        self.path = path
    }

    func login(_ request: LoginRequestDTO) async throws -> LoginResponseDTO {
        let body = try JSONEncoder().encode(request)
        let endpoint = Endpoint(
            path: path,
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body
        )
        return try await client.request(endpoint, as: LoginResponseDTO.self)
    }
}
