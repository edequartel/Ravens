//
//  SpeciesInfoView.swift
//  Ravens
//
//  Created by Eric de Quartel on 03/12/2024.
//
import SwiftUI
import SwiftyBeaver

struct SpeciesInfoView: View {
  var species: Species // Assuming Species is your data model
  var showView: Bool
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var notificationViewModel: NotificationsViewModel
  @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel

  var body: some View {
    VStack(alignment: .leading) {
      if showView { Text("SpeciesInfoView").font(.customTiny) }

      HStack(spacing: 4) {
        if species.date != nil {
          Image(
            systemName: "eye")
          .symbolRenderingMode(.palette)
          .foregroundStyle(rarityColor(value: species.rarity), .clear)
        } else {
          Image(
            systemName: "circle.fill")
          .symbolRenderingMode(.palette)
          .foregroundStyle(rarityColor(value: species.rarity), .clear)

        }

        if !(species.name.isEmpty) {
          Text("\(species.name)")
            .bold()
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundColor(species.recent ?? false ? .red : .primary)
        } else {
          Text("\(species.scientificName)")
            .italic()
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundColor(species.recent ?? false ? .red : .primary)
        }

        Spacer()

        if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.speciesId) {
          Image(systemName: "star.fill")
            .foregroundColor(Color.gray.opacity(0.8))
        }

        if notificationViewModel.isSpeciesIDInRecords(speciesID: species.speciesId) {
          Image(systemSymbol: .clock)
            .foregroundColor(Color.gray.opacity(0.8))
        }

      }

      if let date = species.date {
        HStack {
          DateConversionView(dateString: date, timeString: species.time ?? "")
        }
        .font(.caption)
      }

      if (species.name) != (species.scientificName) {
        HStack {
          Text("\(species.scientificName)")
            .font(.caption)
            .italic()
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }

      HStack {
        let speciesLang = speciesSecondLangViewModel.findSpeciesByID(
          speciesID: species.speciesId)
        if speciesLang?.lowercased() != species.scientificName.lowercased() {
          Text("\(speciesLang ?? "placeholder")")
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
          Spacer()
        } else {
          Text(" ")
        }
      }
    }
  }
}
