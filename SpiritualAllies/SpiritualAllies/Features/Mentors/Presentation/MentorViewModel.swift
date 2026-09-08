import Foundation
import Observation

@MainActor
@Observable
final class MentorViewModel {
    private enum Constants { static let pageSize = 12 }

    enum LoadState: Equatable { case idle, loading, loaded, failed(String) }

    private(set) var state: LoadState = .idle
    private(set) var section: MentorSection?
    private(set) var mentors: [Mentor] = []
    private(set) var isLoadingMore = false
    private(set) var isLastPage = false

    var selectedCategory = "All Mentors"
    var searchText = ""

    private var currentPage = -1
    private var hasAppeared = false
    private let fetchMentors: FetchMentorsUseCase

    init(fetchMentors: FetchMentorsUseCase) { self.fetchMentors = fetchMentors }

    var categories: [String] { section?.categories ?? ["All Mentors"] }

    var filteredMentors: [Mentor] {
        mentors.filter { mentor in
            let category = selectedCategory == "All Mentors"
                || mentor.tags.contains { $0.localizedCaseInsensitiveContains(selectedCategory.replacingOccurrences(of: "All ", with: "")) }
                || mentor.category.localizedCaseInsensitiveContains(selectedCategory.replacingOccurrences(of: "All ", with: ""))
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let search = query.isEmpty || ([mentor.name, mentor.location, mentor.lineage, mentor.languages, mentor.category] + mentor.tags)
                .joined(separator: " ").localizedCaseInsensitiveContains(query)
            return category && search
        }
    }

    var resultCountText: String { "Showing \(filteredMentors.count) of \(section?.totalCount ?? mentors.count) mentors" }

    func onAppear() async {
        guard !hasAppeared else { return }
        hasAppeared = true
        await loadInitialPage()
    }

    func refresh() async {
        hasAppeared = true
        await loadInitialPage()
    }

    func loadMoreIfNeeded(current mentor: Mentor) async {
        guard mentor.id == filteredMentors.last?.id, selectedCategory == "All Mentors", searchText.isEmpty else { return }
        guard !isLoadingMore, !isLastPage else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let page = try await fetchMentors.execute(page: currentPage + 1, size: Constants.pageSize)
            let existing = Set(mentors.map(\.id))
            mentors.append(contentsOf: page.page.items.filter { !existing.contains($0.id) })
            currentPage = page.page.pageNumber
            isLastPage = page.page.isLast || page.page.items.count < Constants.pageSize
            section = MentorSection(eyebrow: page.eyebrow, title: page.title, subtitle: page.subtitle, heroImagePath: page.heroImagePath ?? section?.heroImagePath, totalCount: page.totalCount ?? section?.totalCount, categories: page.categories.isEmpty ? categories : page.categories, page: page.page)
        } catch {
            ToastHelper.toast((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }

    private func loadInitialPage() async {
        state = .loading
        mentors = []
        section = nil
        currentPage = -1
        isLastPage = false
        do {
            let page = try await fetchMentors.execute(page: 0, size: Constants.pageSize)
            section = page
            mentors = page.page.items
            currentPage = page.page.pageNumber
            isLastPage = page.page.isLast || page.page.items.count < Constants.pageSize
            state = .loaded
        } catch {
            state = .failed((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
