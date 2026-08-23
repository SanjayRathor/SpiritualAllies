//
//  AuthSession.swift
//  SpiritualAllies
//
//  Domain entity describing an authenticated session.
//

import Foundation

struct AuthSession: Equatable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let userID: String
    let username: String
    let email: String?
    let fullName: String?
    let roles: [String]
    let locale: String?
}
