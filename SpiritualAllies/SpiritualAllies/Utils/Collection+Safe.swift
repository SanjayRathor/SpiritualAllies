import Foundation

extension Collection {
    /// Returns the element only when `index` belongs to this collection.
    /// Prefer this for indexes derived from APIs, calculations, or user input.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
