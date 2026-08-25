//
//  PlacesViewModel.swift
//  SpiritualAllies
//
//  Presentation state for the Places tab, including paging and category
//  filtering over the loaded results.
//

import Foundation
import Observation

@MainActor
@Observable
final class PlacesViewModel {
    private enum Constants {
        static let pageSize = 12
    }

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: LoadState = .idle
    private(set) var places: [SacredPlace] = []
    private(set) var totalElements: Int?
    private(set) var isLoadingMore = false
    private(set) var isLastPage = false

    var selectedCategory: String = "All"

    private var currentPage: Int = -1
    private var isInitialLoadPerformed = false

    private let fetchPlaces: FetchSacredPlacesUseCase

    init(fetchPlaces: FetchSacredPlacesUseCase) {
        self.fetchPlaces = fetchPlaces
    }

    var availableCategories: [String] {
        var seen = Set<String>()
        var values: [String] = ["All"]

        for place in places {
            let category = place.category.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !category.isEmpty, !seen.contains(category.lowercased()) else { continue }
            seen.insert(category.lowercased())
            values.append(category)
        }

        return values
    }

    var filteredPlaces: [SacredPlace] {
        guard selectedCategory != "All" else { return places }
        return places.filter { $0.category.caseInsensitiveCompare(selectedCategory) == .orderedSame }
    }

    var heroPlace: SacredPlace? {
        filteredPlaces.first ?? places.first
    }

    var heroCountText: String {
        let count = totalElements ?? places.count
        return "\(count) PLACES"
    }

    var hasMorePages: Bool {
        guard !places.isEmpty else { return false }
        if let total = totalElements {
            return places.count < total && !isLastPage
        }
        return !isLastPage
    }

    func onAppear() async {
        guard !isInitialLoadPerformed else { return }
        isInitialLoadPerformed = true
        await loadInitialPage()
    }

    func refresh() async {
        isInitialLoadPerformed = true
        await loadInitialPage()
    }

    func loadMoreIfNeeded(current place: SacredPlace) async {
        guard place.id == filteredPlaces.last?.id else { return }
        await loadNextPageIfNeeded()
    }

    private func loadInitialPage() async {
        state = .loading
        places = []
        totalElements = nil
        isLastPage = false
        currentPage = -1
        isLoadingMore = false
        ToastHelper.showLoading(with: "Loading sacred places")

        do {
            let page = try await fetchPlaces.execute(page: 0, size: Constants.pageSize)
            places = page.items
            totalElements = page.totalElements
            isLastPage = page.isLast || page.items.count < Constants.pageSize
            currentPage = page.pageNumber
            state = .loaded
            ToastHelper.hideLoading()
        } catch {
            ToastHelper.hideLoading()
            let message = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            state = .failed(message)
            ToastHelper.toast(message)
        }
    }

    private func loadNextPageIfNeeded() async {
        guard !isLoadingMore, hasMorePages else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let page = try await fetchPlaces.execute(page: nextPage, size: Constants.pageSize)
            guard !page.items.isEmpty else {
                totalElements = page.totalElements ?? totalElements
                isLastPage = true
                currentPage = page.pageNumber
                return
            }

            let existingIDs = Set(places.map(\.id))
            let newItems = page.items.filter { !existingIDs.contains($0.id) }
            places.append(contentsOf: newItems)
            totalElements = page.totalElements ?? totalElements
            isLastPage = page.isLast || page.items.count < Constants.pageSize
            currentPage = page.pageNumber
        } catch {
            ToastHelper.toast((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
