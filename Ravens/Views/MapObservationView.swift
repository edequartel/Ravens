//
//  MapObservationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapObservationView: View {
    @StateObject private var observationsViewModel = ObservationsViewModel()
    
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.024052, longitude: 5.245350),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    let locations = [
        Location(name: "Mallard", coordinate: CLLocationCoordinate2D(latitude: 52.024052, longitude: -0.141)),
        Location(name: "Little Grebe", coordinate: CLLocationCoordinate2D(latitude: 52.009233, longitude: 5.986369)),
        Location(name: "Woonplaats", coordinate: CLLocationCoordinate2D(latitude: 52.024052, longitude: 5.245350))
    ]
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(position: $position) {
                    ForEach(locations) { location in
                        Marker(location.name, coordinate: location.coordinate)
                    }
//                    ForEach(observationsViewModel.locations()) { location in
//                        Marker(location.name, coordinate: location.coordinate)
//                    }
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        print(coordinate.latitude)
                        print(coordinate.longitude)
                    }
                }
                .mapStyle(.imagery(elevation: .flat))
                .onMapCameraChange { context in
                    print(context.region)
                }
            }
            
        }
        .onAppear(){
            observationsViewModel.fetchData(days: 14, endDate: Date()+14, lat: 52.024052, long: 5.245350, radius: 500)
        }
    }
}

#Preview {
    MapObservationView()
}

//                        Annotation(location.name, coordinate: location.coordinate) {
//                            Text(location.name)
//                                .font(.subheadline)
//                                .padding()
//                                .background(.blue)
//                                .foregroundStyle(.white)
//                                .clipShape(.capsule)
//                        }
//                        .annotationTitles(.hidden)
