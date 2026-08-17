//
//  Photo.swift
//  TodayInSpaceHistory
//

import Kingfisher
import SwiftUI
import UIKit

struct Photo: View {
    let url: URL?
    var isLoading: Bool = false

    init(url: URL?, isLoading: Bool = false) {
        self.url = url
        self.isLoading = isLoading
    }

    init(urlString: String?, isLoading: Bool = false) {
        self.url = urlString.flatMap { URL(string: $0) }
        self.isLoading = isLoading
    }

    var body: some View {
        Color.clear
            .overlay {
                imageContent
            }
            .clipped()
    }

    @ViewBuilder
    private var imageContent: some View {
        if isLoading, url == nil {
            ProgressView()
                .accessibilityIdentifier(AccessibilityIdentifiers.loading)
        } else if let image = localImage {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
        } else if let url, !url.isFileURL {
            KFImage(url)
                .placeholder { Color.clear }
                .onFailureView { placeholder }
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
    }

    private var localImage: UIImage? {
        guard let url, url.isFileURL else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
    }
}

#Preview("Loading") {
    Photo(url: nil, isLoading: true)
        .frame(height: 200)
}

#Preview("Local") {
    Photo(url: UITestStubImageProvider.previewMockURL)
        .frame(height: 200)
}

#Preview("Missing") {
    Photo(url: nil)
        .frame(height: 200)
}
