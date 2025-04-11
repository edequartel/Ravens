//
//  FavoriteObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/04/2025.
//

import Foundation
import SwiftyBeaver

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

    func removeRecord(idObs: Int) {
        if let index = records.firstIndex(where: { $0.idObs == idObs }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with idObs \(idObs) does not exist.")
        }
    }
}

// VIEW
// MARK: - ObservationListView
import SwiftUI

struct FavoObservationListView: View {
    @EnvironmentObject var favoriteObservationsViewModel: FavoriteObservationsViewModel

  var body: some View {
    NavigationView {
      List(favoriteObservationsViewModel.records) { observation in
        VStack(alignment: .leading) {
//          Text("\(String(describing: observation.idObs))")
//            .font(.caption)
          Text("\(observation.speciesDetail.name)")
            .bold()
          Text("\(observation.speciesDetail.scientificName)")
            .italic()
          HStack {
            Text("\(observation.date)")
            Text("\(observation.time ?? "")")
            Spacer()
          }
          .font(.caption)
        }
      }
//      .navigationTitle("Favorites")
    }
  }
}
