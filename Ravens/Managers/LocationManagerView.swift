//
//  LocationManagerView.swift
//  Ravens
//
//  Created by Eric de Quartel on 24/05/2024.
//

import SwiftUI

struct LocationManagerView: View {
    @EnvironmentObject var locationManager: LocationManagerModel

    var body: some View {
        VStack {
            if let location = locationManager.getCurrentLocation() {
                HStack() {
                    Text("GPS ")
                        .bold()
                    Text("Lat \(location.coordinate.latitude, format: .number.precision(.fractionLength(2)))")
                    Text("Long \(location.coordinate.longitude, format: .number.precision(.fractionLength(2)))")
                    Spacer()
                }
            } else if let errorMessage = locationManager.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("Retrieving location...")
            }
        }
        .font(.caption2)
    }
}

struct LocationManagerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationManagerView()
    }
}
