//
//  TokenStore.swift
//  SpiritualAllies
//
//  Holds the auth tokens for the current session. Kept behind a protocol so a
//  persistent (Keychain) implementation can replace the in-memory one later
//  without touching the networking layer.
//

import Foundation

protocol TokenProviding: Sendable {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func update(accessToken: String?, refreshToken: String?)
    func clear()
}

/// Simple in-memory, thread-safe token store. Data persistence is intentionally
/// out of scope for now (per requirements); swap for a Keychain-backed type
/// when persistence is added.
final class InMemoryTokenStore: TokenProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var _accessToken: String?
    private var _refreshToken: String?

    var accessToken: String? { lock.withLock { _accessToken } }
    var refreshToken: String? { lock.withLock { _refreshToken } }

    func update(accessToken: String?, refreshToken: String?) {
        lock.withLock {
            _accessToken = accessToken
            _refreshToken = refreshToken
        }
    }

    func clear() {
        lock.withLock {
            _accessToken = nil
            _refreshToken = nil
        }
    }
}
