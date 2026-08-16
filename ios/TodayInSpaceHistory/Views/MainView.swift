//
//  MainView.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import SwiftUI
import Kingfisher

struct MainView: View {
    @State private var viewModel: MainViewViewModel

    init(viewModel: MainViewViewModel = MainViewViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
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
            await viewModel.fetchData()
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
        Text(viewModel.dayLabel)
            .font(.custom(StyleConstants.lightFont, size: 30))
            .accessibilityIdentifier(AccessibilityIdentifiers.dayLabel)
    }

    @ViewBuilder
    private var imageSection: some View {
        if let imageURL = viewModel.imageURL, let url = URL(string: imageURL) {
            // Container-first layout: fill image cannot expand the parent width.
            RoundedRectangle(cornerRadius: 50)
                .fill(.clear)
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .overlay {
                    KFImage(url)
                        .fade(duration: 0.2)
                        .resizable()
                        .scaledToFill()
                }
                .overlay(alignment: .bottomLeading) {
                    if let title = viewModel.title {
                        Text(title)
                            .font(.custom(StyleConstants.boldFont, size: 15))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.5))
                            .padding([.bottom, .trailing], 20)
                            .accessibilityIdentifier(AccessibilityIdentifiers.imageTitle)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 50))
        } else if viewModel.isLoading {
            ProgressView()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(AccessibilityIdentifiers.loading)
        }
    }

    private var descriptionSection: some View {
        ScrollView {
            Text(viewModel.description ?? "")
                .font(.custom(StyleConstants.fontName, size: 20))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(AccessibilityIdentifiers.description)
        }
    }
}

#Preview {
    MainView()
}
