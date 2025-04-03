//
//  settingsDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/01/2024.
//

import SwiftUI

struct SettingsDetailsView: View {
  @EnvironmentObject var settings: Settings
  @EnvironmentObject var areasViewModel: AreasViewModel

  var body: some View {
    VStack {
      VStack {
        HStack {
          Text(settings.locationName)
            .bold()
            .lineLimit(1)
            .truncationMode(.tail)
          Spacer()
        }
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(settings.locationName)")
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EE dd-MM"
    return formatter
  }
}

#Preview {
  SettingsDetailsView()
    .environmentObject(Settings())
}
