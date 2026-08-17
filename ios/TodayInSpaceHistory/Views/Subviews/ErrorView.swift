//
//  ErrorView.swift
//  TodayInSpaceHistory
//
//  Created by Mikolaj Linczewski on 17/08/2026.
//

import SwiftUI

struct ErrorView: View {
    @State private var error: DescriptiveError
    public init(error: DescriptiveError) {
        self.error = error
    }
    var body: some View {
        Image(systemName: "")
        Text(error.title)
        Text(error.description)
        
    }
}

#Preview("error") {
    ErrorView(error: Errors.NetworkClient.invalidURL(endpointOrPath: "bad url"))
}
