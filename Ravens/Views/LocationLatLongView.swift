//
//  LocationLatLongView.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import SwiftUI
import MapKit

struct LocationLatLongView: View {
    @StateObject private var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.locations, id: \.id) { location in
                VStack(alignment: .leading) {
                    Text(location.name).font(.headline)
                    Text("\(location.id)").font(.headline)
                    Text(location.country_code).font(.subheadline)
                    Link("View on Website", destination: URL(string: location.permalink)!)
                }
            }
            .navigationBarTitle("Locations")
            .onAppear {
                viewModel.fetchLocations(latitude: 52.141411, longitude: 6.195310) { fetchedLocations in
                    // Use fetchedLocations here
                    for location in fetchedLocations {
                        print(location)
                    }
                }
            }
        }
    }
}

#Preview {
    LocationLatLongView()
}
