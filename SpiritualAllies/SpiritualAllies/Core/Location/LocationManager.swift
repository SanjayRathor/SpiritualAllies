//
//  LocationManager.swift
//  SpiritualAllies
//
//  Async/await wrapper around CoreLocation that requests when-in-use
//  permission, fetches a single fix and reverse-geocodes it to a country.
//

import CoreLocation
import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class LocationManager {
    enum State: Equatable {
        case idle
        case requesting
        case authorized
        case denied
        case restricted
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var country: String?
    private(set) var countryCode: String?
    private(set) var locality: String?
    private(set) var coordinate: CLLocationCoordinate2D?

    /// Fallback shown until a real location is resolved or when access is denied.
    let defaultCountry: String


    init(defaultCountry: String = "India") {
        self.defaultCountry = defaultCountry
    }

    /// Country to display in UI: resolved country, else the default.
    var displayCountry: String { country ?? defaultCountry }

    var isAuthorized: Bool {
        switch CLLocationManager().authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }

    /// Requests permission (if needed), waits for the first location fix and
    /// resolves the user's country. Gives up after `timeout` seconds so the UI
    /// never stays in a loading state. Safe to call multiple times.
    func resolveCountry(timeout: Duration = .seconds(10)) async {
        guard state != .requesting else { return }
        state = .requesting

        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }

        do {
            let outcome = try await withThrowingTaskGroup(of: Outcome.self) { group in
                group.addTask { try await Self.firstFix() }
                group.addTask {
                    try await Task.sleep(for: timeout)
                    return .timedOut
                }
                let first = try await group.next() ?? .timedOut
                group.cancelAll()
                return first
            }

            switch outcome {
            case .fix(let location):
                coordinate = location.coordinate
                state = .authorized
                await reverseGeocode(location)
            case .denied: state = .denied
            case .restricted: state = .restricted
            case .unavailable: state = .failed("Location is currently unavailable.")
            case .timedOut: state = .failed("Timed out waiting for a location fix.")
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private enum Outcome: Sendable {
        case fix(CLLocation)
        case denied
        case restricted
        case unavailable
        case timedOut
    }

    private static func firstFix() async throws -> Outcome {
        for try await update in CLLocationUpdate.liveUpdates() {
            if update.authorizationDenied || update.authorizationDeniedGlobally { return .denied }
            if update.authorizationRestricted { return .restricted }
            if update.authorizationRequestInProgress { continue }
            if update.locationUnavailable || update.serviceSessionRequired || update.insufficientlyInUse {
                return .unavailable
            }
            if let location = update.location { return .fix(location) }
        }
        return .unavailable
    }

    private func reverseGeocode(_ location: CLLocation) async {
        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try? await request.mapItems.first,
              let address = item.addressRepresentations else { return }
        countryCode = address.region?.identifier
        country = countryCode.flatMap { Locale.current.localizedString(forRegionCode: $0) }
        locality = address.cityName
    }
}
