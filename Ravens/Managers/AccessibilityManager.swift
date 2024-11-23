//
//  AccessibilityManager.swift
//  Ravens
//
//  Created by Eric de Quartel on 23/11/2024.
//

import SwiftUI
import Combine

class AccessibilityManager: ObservableObject {
    @Published var isVoiceOverEnabled: Bool = UIAccessibility.isVoiceOverRunning

    private var cancellable: AnyCancellable?

    init() {
        // Observe VoiceOver status changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverStatusChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func voiceOverStatusChanged() {
        DispatchQueue.main.async {
            self.isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
