//
//  settingsDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/01/2024.
//

import SwiftUI

struct SettingsDetailsView: View {
    @EnvironmentObject var settings: Settings
    var body: some View {
        HStack {
            Spacer()
            Text("\(settings.selectedGroupString)")
            Text("(\(settings.selectedRarity))")
            Text("\(settings.days)d")
            Text("\(settings.selectedDate, formatter: dateFormatter)")
        }
        .padding(2)
        .font(.footnote)
        .foregroundColor(.obsGreenFlower)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
            formatter.dateFormat = "EE dd-MM"
//            formatter.dateStyle = .short
//            formatter.timeStyle = .short
            return formatter
        }
}

#Preview {
    SettingsDetailsView()
        .environmentObject(Settings())
}
