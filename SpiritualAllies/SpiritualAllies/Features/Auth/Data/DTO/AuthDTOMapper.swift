//
//  AuthDTOMapper.swift
//  SpiritualAllies
//
//  Maps the login response DTO into the AuthSession domain entity.
//

import Foundation

enum AuthDTOMapper {
    static func map(_ dto: LoginResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            tokenType: dto.tokenType,
            expiresIn: dto.expiresIn,
            userID: dto.userId,
            username: dto.username,
            email: dto.email,
            fullName: dto.fullName,
            roles: dto.roles ?? [],
            locale: dto.preferences?.locale
        )
    }
}
