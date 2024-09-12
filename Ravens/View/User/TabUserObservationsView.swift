//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabUserObservationsView: View {
  @EnvironmentObject var settings: Settings
  @State private var showFirstView = false


  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }
        if showFirstView && !settings.accessibility {
          MapObservationsUserView()
        } else {
          ObservationsUserView()
        }
      }
      .toolbar {
        if !settings.accessibility {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              showFirstView.toggle()
            }) {
              Image(systemName: "rectangle.2.swap")
            }
          }
        }
      }
      .navigationTitle("\(settings.userName)")
      .navigationBarTitleDisplayMode(.inline)
      .onAppearOnce {
        showFirstView = settings.mapPreference
      }
    }
  }
}

struct TabUserObservationsView_Previews: PreviewProvider {
  @State static var selectedObservation: Observation? = nil
  @State static var selectedObservationSound: Observation? = nil
  @StateObject static var observationsUserViewModel = ObservationsViewModel()

  static var previews: some View {
    TabUserObservationsView()
//      selectedObservationSound: $selectedObservationSound,
//      selectedObs: .constant(nil))
//      imageURLStr: .constant(""))
    .environmentObject(Settings())
    .environmentObject(observationsUserViewModel)
  }
}
