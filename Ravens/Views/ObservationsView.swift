//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
import MapKit

struct ObservationsView: View {
    @StateObject private var observationsViewModel = ObservationsViewModel()
    
    @State private var selectedDate = Date()
    
    var location = [Location]()
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                    .onChange(of: selectedDate) { newDate in
                        // Perform your action when the date changes
                        observationsViewModel.fetchData(days: 7, endDate: selectedDate, lat: 52.024052, long: 5.245350, radius: 500)
                    }
                Section("List") {
                    List {
                        if let observations = observationsViewModel.observations?.results {
                            ForEach(observations.sorted(by: { $0.species_detail.name < $1.species_detail.name }), id: \.id) { result in
                                VStack(alignment: .leading) {
                                    Text("\(result.species_detail.name)")
                                        .font(.subheadline)
                                    Text("User: \(result.user)")
                                        .font(.subheadline)
                                    // Text("\(result.point.coordinates[0])")
                                    // Text("\(result.point.coordinates[1])")
                                }
                            }
                        } else {
                            // Handle the case when observationsViewModel.observations?.results is nil
                            Text("No observations available")
                        }
                    }
                }
            }
        }
        .onAppear(){
            observationsViewModel.fetchData(days: 7, endDate: selectedDate, lat: 52.024052, long: 5.245350, radius: 500)
        }
    }
}

#Preview {
    ObservationsView()
}
