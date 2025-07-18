//
//  FavoriteObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/04/2025.
//

import Foundation
import SwiftyBeaver
import MijickCalendarView
import SwiftData

class FavoriteObservationsViewModel: ObservableObject {
  let log = SwiftyBeaver.self

  @Published var records: [Obs] = []
  let filePath: URL

  init(fileName: String = "") {
    log.error("init FavoriteObservationsViewModel with file: \(fileName)")

    let fileManager = FileManager.default

    if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil)?
      .appendingPathComponent("Documents") {
      try? fileManager.createDirectory(at: ubiquityURL, withIntermediateDirectories: true)
      self.filePath = ubiquityURL.appendingPathComponent(fileName)
      log.error("Using iCloud path: \(filePath.path)")
    } else {
      let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      self.filePath = documentsPath.appendingPathComponent(fileName)
      log.error("iCloud unavailable, using local path: \(filePath.path)")
    }

    if !fileManager.fileExists(atPath: filePath.path) {
      fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
    }

    loadRecords()
  }

  func loadRecords() {
    do {
      let data = try Data(contentsOf: filePath)
      records = try JSONDecoder().decode([Obs].self, from: data)
      log.info("Loaded \(records.count) favorite observations")
    } catch {
      log.info("Error loading data from \(filePath.lastPathComponent) - likely empty")
    }
  }

  func saveRecords() {
    do {
      let data = try JSONEncoder().encode(records)
      try data.write(to: filePath, options: .atomicWrite)
    } catch {
      print("Error saving data: \(error)")
    }
  }

  func isObservationInRecords(idObs: Int) -> Bool {
    records.contains(where: { $0.idObs == idObs })
  }

  func appendRecord(observation: Obs) {
    guard !records.contains(where: { $0.idObs == observation.idObs }) else {
      print("Record with idObs \(String(describing: observation.idObs)) already exists.")
      return
    }
    records.append(observation)
    saveRecords()
  }

  func removeRecord(observation: Obs) {
    if let index = records.firstIndex(where: { $0.idObs == observation.idObs }) {
      records.remove(at: index)
      saveRecords()
    } else {
      print("Record with idObs \(String(describing: observation.idObs)) does not exist.")
    }
  }
}

// VIEW
// MARK: - ObservationListView
import SwiftUI

struct FavoObservationListView: View {
  @EnvironmentObject var favoriteObservationsViewModel: FavoriteObservationsViewModel

  var allObservationNamesText: String {
    let rows = favoriteObservationsViewModel.records.map {
      let name = $0.speciesDetail.name.padding(toLength: 12, withPad: " ", startingAt: 0)
      let number = "\($0.number)x"
      let date = "\($0.date)"
      return "\(name) \(date) \(number)"
    }.joined(separator: "\n")

    return "```\(rows)\n```"
  }

  var body: some View {
    NavigationStack {
      HorizontalLine()
      if showView { Text("FavoObservationListView").font(.customTiny) }
      VStack {
        //        MCalendarView(selectedDate: $selectedDate, selectedRange: $selectedRange)
        //        let groupedRecords = Dictionary(grouping: favoriteObservationsViewModel.records) { $0.speciesDetail.name }

        let groupedRecords: [String: [Obs]] = Dictionary(grouping: favoriteObservationsViewModel.records) { $0.speciesDetail.name }
          .mapValues { $0.sorted(by: { $0.date < $1.date }) }
        let sortedKeys = groupedRecords.keys.sorted()

        List {
          ForEach(sortedKeys, id: \.self) { name in
            if let records = groupedRecords[name] {
              Section(header: Text(name).bold()) {
                ForEach(records) { observation in

                  NavigationLink(
                    destination: ObsDetailView(
                      obs: observation,
                      entity: .species)  
                  ) {
                    HStack {
                      Text("\(observation.date)")
                        .bold()

                      Text("  \(observation.locationDetail?.name ?? "")")
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(observation.date), \(observation.locationDetail?.name ?? "")")
                    .font(.caption)
                  }
                  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                      favoriteObservationsViewModel.removeRecord(observation: observation)
                    } label: {
                      Image(systemSymbol: .bookmarkSlash)
                    }
                    .tint(.red)
                  }
                }
              }
            }
          }
        }
        .listStyle(GroupedListStyle())

        Spacer()
      }

      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(favoFavorites)

      }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        ShareLink(
            item: allObservationNamesText,
            subject: Text(observations)//,
//            preview: SharePreview(observations, image: Image("AppIconShare")) //??
        ) {
            Label(shareObservations, systemSymbol: .squareAndArrowUp)
        }
        .accessibility(label: Text(share))
      }
    }
  }

}
