//
//  FavoriteObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/04/2025.
//

import Foundation
import SwiftyBeaver
import MijickCalendarView

class FavoriteObservationsViewModel: ObservableObject {
    let log = SwiftyBeaver.self

    @Published var records: [Observation] = []
    let filePath: URL

    init(fileName: String = "favoriteObservations.json") {
        log.info("init FavoriteObservationsViewModel with file: \(fileName)")

        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.filePath = documentsPath.appendingPathComponent(fileName)

        if !fileManager.fileExists(atPath: filePath.path) {
            fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        }

        loadRecords()
    }

    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Observation].self, from: data)
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

    func appendRecord(observation: Observation) {
        guard !records.contains(where: { $0.idObs == observation.idObs }) else {
          print("Record with idObs \(String(describing: observation.idObs)) already exists.")
            return
        }
        records.append(observation)
        saveRecords()
    }

  func removeRecord(observation: Observation) {
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
//  @State private var selectedDate: Date?
//  @State private var selectedRange: MDateRange? = .init()

  var body: some View {
    NavigationStack {
      HorizontalLine()
      VStack {
        //        MCalendarView(selectedDate: $selectedDate, selectedRange: $selectedRange)

//        let groupedRecords = Dictionary(grouping: favoriteObservationsViewModel.records) { $0.speciesDetail.name }

        let groupedRecords: [String: [Observation]] = Dictionary(grouping: favoriteObservationsViewModel.records) { $0.speciesDetail.name }
          .mapValues { $0.sorted(by: { $0.date < $1.date }) }
        let sortedKeys = groupedRecords.keys.sorted()

        List {
          ForEach(sortedKeys, id: \.self) { name in
            if let records = groupedRecords[name] {
              Section(header: Text(name).bold()) {

                ForEach(records) { observation in
                  VStack(alignment: .leading) {
//                    Text("\(observation.speciesDetail.name)")
//                      .bold()
//                    Text("\(observation.speciesDetail.scientificName)")
//                      .italic()
//                    Text("\(observation.locationDetail?.name ?? "")") //??
//                      .font(.caption)
//                    Text("\(observation.userDetail?.name ?? "")") //??
//                      .font(.caption)
                    HStack {
                      HStack {
                        Text("\(observation.date)")
                        Text("\(observation.time ?? "")")

                      }
                      .bold()
                      .font(.caption)

                      Text("  \(observation.locationDetail?.name ?? "")") //??
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                  }
                  .swipeActions(edge: .trailing, allowsFullSwipe: false ) {
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
        .listStyle(.plain)
        Spacer()
      }

      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Favorites")
    }
  }
}
