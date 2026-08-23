//
//  AppEnvironment.swift
//  SpiritualAllies
//
//  Central place for environment-specific configuration such as base URLs.
//

import Foundation

/// Describes a runtime environment (dev / staging / prod).
/// Kept small and value-typed so it is trivial to inject and swap in tests.
struct AppEnvironment {
    /// Base URL used for REST API calls (once real APIs are wired up).
    let apiBaseURL: URL
    /// Base URL used to resolve relative image paths coming from the backend
    /// (e.g. "/images/landing/hero-offerings.jpg").
    let imageBaseURL: URL

    static let production = AppEnvironment(
        apiBaseURL: URL(string: "https://spiritualallies.com/api")!,
        imageBaseURL: URL(string: "https://spiritualallies.com")!
    )

    /// The environment currently in use across the app.
    static let current = production
}
