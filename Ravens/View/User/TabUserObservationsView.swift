//
//  UserObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct TabUserObservationsView: View {
  @EnvironmentObject var settings: Settings
//  @StateObject var bookMarksViewModel = BookMarksViewModel()
//  @EnvironmentObject var observersViewModel: ObserversViewModel
//  @StateObject var areasViewModel = AreasViewModel()
  @State private var showFirstView = false

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    NavigationView {
      VStack {
        if showView { Text("TabUserObservationsView").font(.customTiny) }
        if showFirstView && !settings.accessibility {
          MapObservationsUserView()
        } else {
          ObservationsUserView(selectedSpeciesID: $selectedSpeciesID)
        }
      }
//      .navigationBarTitleDisplayMode(.inline)

      .toolbar {
        if !settings.accessibility {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              showFirstView.toggle()
            }) {
              Image(systemName: "rectangle.2.swap")
                .accessibility(label: Text("Switch view"))
            }
          }


          //add a toolbaritem here to the list of users
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(destination: ObserversView()) {
              Image(systemName: "list.bullet")
                .accessibility(label: Text("list users"))
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
  @StateObject static var observationsUserViewModel = ObservationsViewModel()

  static var previews: some View {
    TabUserObservationsView(selectedSpeciesID: .constant(nil))
    .environmentObject(Settings())
    .environmentObject(observationsUserViewModel)
  }
}
