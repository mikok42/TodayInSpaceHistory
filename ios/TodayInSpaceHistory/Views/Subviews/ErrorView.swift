//
//  ErrorView.swift
//  TodayInSpaceHistory
//
//  Created by Mikolaj Linczewski on 17/08/2026.
//

import SwiftUI

struct ErrorView: View {
    @State private var error: DescriptiveError
    
    public init(error: DescriptiveError, onDismiss: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
    }
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        Image(systemName: "")
        Text(error.title)
        Text(error.description)
        Button("Dismiss") {
            onDismiss?()
        }
        
    }
}

#Preview("error") {
    ErrorView(error: Errors.NetworkClient.invalidURL(endpointOrPath: "bad url"))
}
