//
//  AuthDTO.swift
//  SpiritualAllies
//
//  Codable DTOs for the /auth/login request and response.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let username: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let userId: String
    let username: String
    let email: String?
    let fullName: String?
    let roles: [String]?
    let preferences: PreferencesDTO?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case userId = "user_id"
        case username
        case email
        case fullName = "full_name"
        case roles
        case preferences
    }
}

struct PreferencesDTO: Decodable {
    let locale: String?
    let displayCurrency: String?
    let region_code: String?

    enum CodingKeys: String, CodingKey {
        case locale
        case displayCurrency = "display_currency"
        case region_code
    }
}
