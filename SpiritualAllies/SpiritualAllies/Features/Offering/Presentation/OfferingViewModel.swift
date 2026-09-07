//
//  OfferingViewModel.swift
//  SpiritualAllies
//

import Foundation
import Observation

@MainActor
@Observable
final class OfferingViewModel {
    private enum Constants { static let pageSize = 12 }

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: LoadState = .idle
    private(set) var section: OfferingSection?
    private(set) var offerings: [Offering] = []
    private(set) var isLoadingMore = false
    private(set) var isLastPage = false

    var selectedCategory = "All Offerings"
    var searchText = ""

    private var currentPage = -1
    private var hasAppeared = false
    private let fetchOfferings: FetchOfferingsUseCase

    init(fetchOfferings: FetchOfferingsUseCase) { self.fetchOfferings = fetchOfferings }

    var categories: [String] { section?.categories ?? ["All Offerings"] }

    var filteredOfferings: [Offering] {
        offerings.filter { item in
            let category = selectedCategory == "All Offerings"
                || item.category.localizedCaseInsensitiveContains(selectedCategory.replacingOccurrences(of: "All ", with: ""))
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let search = query.isEmpty || [item.title, item.location, item.category, item.details]
                .joined(separator: " ").localizedCaseInsensitiveContains(query)
            return category && search
        }
    }

    var resultCountText: String {
        "Showing \(filteredOfferings.count) of \(section?.totalCount ?? offerings.count) offerings"
    }

    func onAppear() async {
        guard !hasAppeared else { return }
        hasAppeared = true
        await loadInitialPage()
    }

    func refresh() async {
        hasAppeared = true
        await loadInitialPage()
    }

    func loadMoreIfNeeded(current item: Offering) async {
        guard item.id == filteredOfferings.last?.id, selectedCategory == "All Offerings", searchText.isEmpty else { return }
        await loadNextPageIfNeeded()
    }

    private func loadInitialPage() async {
        state = .loading
        offerings = []
        section = nil
        currentPage = -1
        isLastPage = false
        do {
            let response = try await fetchOfferings.execute(page: 0, size: Constants.pageSize)
            section = response
            offerings = response.page.items
            currentPage = response.page.pageNumber
            isLastPage = response.page.isLast || response.page.items.count < Constants.pageSize
            state = .loaded
        } catch {
            state = .failed((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }

    private func loadNextPageIfNeeded() async {
        guard !isLoadingMore, !isLastPage else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let response = try await fetchOfferings.execute(page: currentPage + 1, size: Constants.pageSize)
            let existingIDs = Set(offerings.map(\.id))
            offerings.append(contentsOf: response.page.items.filter { !existingIDs.contains($0.id) })
            if let current = section {
                section = OfferingSection(
                    eyebrow: response.eyebrow,
                    title: response.title,
                    subtitle: response.subtitle,
                    heroImagePath: response.heroImagePath ?? current.heroImagePath,
                    totalCount: response.totalCount ?? current.totalCount,
                    categories: response.categories.isEmpty ? current.categories : response.categories,
                    page: response.page
                )
            }
            currentPage = response.page.pageNumber
            isLastPage = response.page.isLast || response.page.items.count < Constants.pageSize
        } catch {
            ToastHelper.toast((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
