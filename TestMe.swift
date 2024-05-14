//
//  TestMe.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/05/2024.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update the controller here
    }
}

struct ShareTextView: View {
    @State private var showingShareSheet = false
    @State private var textToShare = "Hello from my SwiftUI App!"

    var body: some View {
        Button("Share Text") {
            self.showingShareSheet = true
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [self.textToShare])
        }
    }
}
