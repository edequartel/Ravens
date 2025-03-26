//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import Charts

struct SpeciesView: View {
  @State private var showFirstView = false

  @ObservedObject var observationsSpecies: ObservationsViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel

  @State var showChart: Bool = false

  var item: Species
  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {
      if showView { Text("SpeciesView").font(.customTiny) }
      if showFirstView && !accessibilityManager.isVoiceOverEnabled {
        MapObservationsSpeciesView(
          observationsSpecies: observationsSpecies,
          item: item)
      } else {
        VStack {

          ObservationsSpeciesView(
            observationsSpecies: observationsSpecies,
            item: item,
            selectedSpeciesID: $selectedSpeciesID
          )
        }
      }
    }

    .toolbar {

      ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: BirdListView(scientificName: item.scientificName, nativeName: item.name)) {
              Image(systemSymbol: .waveform)
                  .uniformSize()
          }
          .background(Color.clear)
          .accessibility(label: Text("Audio BirdListView"))
      }

      ToolbarItem(placement: .navigationBarTrailing) { //@@
        NavigationLink(destination: SpeciesDetailsView(speciesID: item.speciesId)) {
          Image(systemSymbol: .infoCircle)
                  .uniformSize()
          }
          .background(Color.clear)
          .accessibility(label: Text("SpeciesDetailsView"))

      }

//      ToolbarItem(placement: .navigationBarTrailing) {
//        Button(action: {
//          selectedSpeciesID = item.speciesId
//        }) {
//          Image(systemSymbol: .infoCircle)
//            .uniformSize()
//        }
//        .tint(.blue)
//      }


      //      ToolbarItem(placement: .navigationBarTrailing) {
      //        Button(action: {
      //          showChart.toggle()
      //        }) {
      //          Image(systemSymbol: .chartBarXaxis)
      //            .uniformSize()
      //        }
      //        .background(Color.clear)
      //      }


      if !accessibilityManager.isVoiceOverEnabled {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFirstView.toggle()
          }) {
            Image(systemSymbol: .rectangle2Swap) // Replace with your desired image
              .uniformSize()
          }
          .accessibility(label: Text("Switch view"))
        }
      }
    }
//    .sheet(isPresented: $showChart) {
//      ObservationsChartView(observations: observationsSpecies.observations ?? [], name: item.name)
//    }

    .onAppear() {
      settings.initialSpeciesLoad = true
    }
  }
}


import SwiftUI
import Charts

struct ObservationsChartView: View {
  var observations: [Observation]
  var name : String = ""

  // Step 1: Group and count observations by DD-MM
  private var groupedObservations: [(date: String, count: Int)] {
    let grouped = Dictionary(grouping: observations, by: { dateToDayMonth($0.date) })
    return grouped.map { (date: $0.key, count: $0.value.count) }
      .sorted { $0.date < $1.date } // Ensure chronological order
  }

  // Extracts "DD-MM" from "YY-MM-DD"
  private func dateToDayMonth(_ fullDate: String) -> String {
    let components = fullDate.split(separator: "-")
    guard components.count == 3 else { return fullDate }
    return "\(components[2])-\(components[1])"  // Extracts "DD-MM"
  }

  var body: some View {
    VStack {
      Text("Laatste \(observations.count) obs \(name)")
        .font(.caption)
        .padding()
      Chart {
        ForEach(groupedObservations, id: \.date) { entry in
          BarMark(
            x: .value("Date", entry.date),
            y: .value("Observations", entry.count)
          )
        }
      }
      .rotationEffect(.degrees(90)) // Rotate chart
      .frame(height: 300)
      .frame(width: 500)
      .padding()
    }
  }
}


