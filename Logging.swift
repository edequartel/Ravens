//
//  Logging.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/08/2025.
//

import Foundation
import Combine

class LogStore: ObservableObject {
  static let shared = LogStore()

  @Published var logs: [String] = []

  func log(_ message: String) {
    let timestamp = Self.now()
    DispatchQueue.main.async {
      self.logs.append("📝 \(timestamp) — \(message)")
      if self.logs.count > 500 { self.logs.removeFirst() }
    }
  }

  static func now() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: Date())
  }
}

///
import SwiftUI

struct LiveLogView: View {
  @ObservedObject var logger = LogStore.shared

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Debug Log").font(.headline).padding(.bottom, 4)
        Spacer()
        Button(action: {
          logger.logs.removeAll()
        }) {
          Image(systemName: "trash")
        }
      }

      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 2) {
            ForEach(Array(logger.logs.enumerated()), id: \.0) { index, log in
              Text(log)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.gray)
                .id(index)
            }
          }
          .padding(.horizontal, 4)
        }
        .onChange(of: logger.logs.count) {
          proxy.scrollTo(logger.logs.count - 1)
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
//    .toolbar {
//      ToolbarItem(placement: .navigationBarTrailing) {
//        Button(action: {
//          logger.logs.removeAll()
//        }) {
//          Image(systemName: "trash")
//        }
//        .accessibilityLabel("Clear Logs")
//      }
//    }
  }
}
