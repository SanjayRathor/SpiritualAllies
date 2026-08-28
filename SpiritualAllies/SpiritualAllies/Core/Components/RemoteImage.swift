//
//  RemoteImage.swift
//  SpiritualAllies
//
//  SwiftUI wrapper around AlamofireImage's ImageDownloader providing async
//  loading + in-memory/disk caching. Relative backend paths (e.g.
//  "/images/landing/hero.jpg") are resolved against the environment image URL.
//

import SwiftUI
import Observation
import AlamofireImage
import Alamofire

/// Loads and caches a remote image via AlamofireImage.
@MainActor
@Observable
final class RemoteImageLoader {
    var image: UIImage?
    var isLoading = false

    private let downloader = ImageDownloader.default

    /// Resolves a possibly-relative path into an absolute image URL.
    static func resolve(_ path: String) -> URL? {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return URL(string: path)
        }
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return AppEnvironment.current.imageBaseURL.appendingPathComponent(trimmed)
    }

    func load(path: String?) {
        guard let path, let url = Self.resolve(path) else { return }
        isLoading = true
        downloader.download(URLRequest(url: url)) { [weak self] response in
            Task { @MainActor in
                self?.isLoading = false
                if case .success(let img) = response.result {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self?.image = img
                    }
                }
            }
        }
    }
}

/// Displays a remote image with a themed placeholder while loading.
struct RemoteImage<Placeholder: View>: View {
    let path: String?
    private let placeholder: Placeholder

    @State private var loader = RemoteImageLoader()

    init(path: String?, @ViewBuilder placeholder: () -> Placeholder) {
        self.path = path
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
        .onAppear { loader.load(path: path) }
        .onChange(of: path) { _, newValue in
            loader.image = nil
            loader.load(path: newValue)
        }
    }
}

extension RemoteImage where Placeholder == AnyView {
    /// Convenience initializer with a default shimmering placeholder.
    init(path: String?) {
        self.init(path: path) {
            AnyView(
                AppColor.primary.opacity(0.15)
                    .overlay(ProgressView().tint(AppColor.accent))
            )
        }
    }
}
