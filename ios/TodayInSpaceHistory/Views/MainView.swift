//
//  MainView.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel: MainViewViewModel

    init(viewModel: MainViewViewModel = MainViewViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        if let error = viewModel.viewProperties.error { ErrorView(error: error, onDismiss: { viewModel.viewProperties.error = nil }) }
        else {
            VStack(alignment: .leading, spacing: StyleConstants.labelsMargins) {
                header
                dayLabel
                imageSection
                descriptionSection
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .foregroundStyle(.white)
            .background(.black)
            .task {
                guard viewModel.viewProperties.imageURL == nil else { return }
                await viewModel.fetchData()
            }
        }
        
    }

    private var header: some View {
        HStack {
            Text("Today In Space History")
                .font(.custom(StyleConstants.lightFont, size: 25))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .accessibilityIdentifier(AccessibilityIdentifiers.title)
            Spacer()
            Button {
                Task { await viewModel.fetchData() }
            } label: {
                Text("↺")
                    .font(.system(size: 25))
                    .foregroundStyle(.white)
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.refresh)
        }
    }

    private var dayLabel: some View {
        Text(viewModel.viewProperties.dayLabel)
            .font(.custom(StyleConstants.lightFont, size: 30))
            .accessibilityIdentifier(AccessibilityIdentifiers.dayLabel)
    }

    @ViewBuilder
    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            Photo(urlString: viewModel.viewProperties.imageURL, isLoading: viewModel.viewProperties.isLoading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let title = viewModel.viewProperties.title {
                Text(title)
                    .font(.custom(StyleConstants.boldFont, size: 15))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.white.opacity(0.5))
                    .padding([.bottom, .trailing], 20)
                    .accessibilityIdentifier(AccessibilityIdentifiers.imageTitle)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var descriptionSection: some View {
        ScrollView {
            Text(viewModel.viewProperties.description ?? "")
                .font(.custom(StyleConstants.fontName, size: 20))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(AccessibilityIdentifiers.description)
        }
    }
}

#Preview("Loaded") {
    MainView(viewModel: MainViewViewModel(imageProvider: UITestStubImageProvider()))
}
