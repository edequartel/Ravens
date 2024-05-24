//
//  LocationManagerView.swift
//  Ravens
//
//  Created by Eric de Quartel on 24/05/2024.
//

import SwiftUI

struct LocationManagerView: View {
//    @EnvironmentObject var locationManager: LocationManagerModel
    @StateObject var locationManager = LocationManagerModel()

    var body: some View {
        VStack {
            if let location = locationManager.location {
                VStack(alignment: .leading) {
                    Text("GPS Location")
                        .bold()
                    Text("Latitude: \(location.coordinate.latitude)")
                    Text("Longitude: \(location.coordinate.longitude)")
                }
            } else if let errorMessage = locationManager.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Retrieving location...")
            }
            
            Button(action: {
                if let currentLocation = locationManager.getCurrentLocation() {
                    print("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
                } else {
                    print("Location not available")
                }
            }) {
                Text("Get Current Location")
//                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
//        .padding()
    }
}

struct LocationManagerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationManagerView()
    }
}
