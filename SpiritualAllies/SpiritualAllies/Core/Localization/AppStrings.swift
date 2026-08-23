//
//  AppStrings.swift
//  SpiritualAllies
//
//  Centralized, localized string accessors. Keys resolve against
//  Localizable.xcstrings so all copy is translation-ready.
//

import Foundation

enum AppStrings {
    enum Error {
        static var noInternet: String { String(localized: "error.noInternet") }
        static var generic: String { String(localized: "common.error.generic") }
    }
}
