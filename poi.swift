////
////  poi.swift
////  Ravens
////
////  Created by Eric de Quartel on 28/03/2024.
////
//
//import SwiftUI
//import CoreLocation
//
//// MARK: - Data Model
//struct LocationContainer: Codable {
//    let locations: [Location]
//}
//
//struct LocationPoi: Codable, Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: Coordinate
//    
//    struct Coordinate: Codable {
//        let latitude: Double
//        let longitude: Double
//        
//        // Helper to convert to CLLocationCoordinate2D
//        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
//            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        }
//    }
//}
//
//// MARK: - ViewModel
//class LocationsViewModel: ObservableObject {
//    @Published var locations: [LocationPoi] = []
//    
//    init() {
//        loadLocations()
//    }
//    
//    func loadLocations() {
//        let jsonString = """
//        {
//            "locations": [
//                {
//                    "name": "IJmuiden",
//                    "coordinate": {
//                        "latitude": 52.459402,
//                        "longitude": 4.540332
//                    }
//                },
//                {
//                    "name": "Oostvaardersplassen",
//                    "coordinate": {
//                        "latitude": 52.452926,
//                        "longitude": 5.357325
//                    }
//                },
//                {
//                    "name": "Brouwersdam",
//                    "coordinate": {
//                        "latitude": 51.761799,
//                        "longitude": 3.853920
//                    }
//                },
//                {
//                    "name": "Mokbaai",
//                    "coordinate": {
//                        "latitude": 53.005861,
//                        "longitude": 4.762873
//                    }
//                },
//                {
//                    "name": "De groene Jonker",
//                    "coordinate": {
//                        "latitude": 52.180458,
//                        "longitude": 4.825451
//                    }
//                },
//                {
//                    "name": "Lauwersoog",
//                    "coordinate": {
//                        "latitude": 53.381690,
//                        "longitude": 6.188163
//                    }
//                },
//                {
//                    "name": "De zouweboezem",
//                    "coordinate": {
//                        "latitude": 51.948497,
//                        "longitude": 4.995383
//                    }
//                },
//                {
//                    "name": "Blauwe kamer",
//                    "coordinate": {
//                        "latitude": 51.942360,
//                        "longitude": 5.610475
//                    }
//                },
//                {
//                    "name": "Steenwaard",
//                    "coordinate": {
//                        "latitude": 51.965423,
//                        "longitude": 5.215302
//                    }
//                }
//            ]
//        }
//        """
//        
//        guard let jsonData = jsonString.data(using: .utf8) else { return }
//        
//        do {
//            let decodedData = try JSONDecoder().decode(LocationContainer.self, from: jsonData)
//            self.locations = decodedData.locations
//        } catch {
//            print("Error decoding JSON: \(error)")
//        }
//    }
//}
//
//// MARK: - SwiftUI View
//struct LocationsView: View {
//    @ObservedObject var viewModel = LocationsViewModel()
//    
//    var body: some View {
//        NavigationView {
//            List(viewModel.locations) { location in
//                VStack(alignment: .leading) {
//                    Text(location.name).bold()
//                    Text("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            .navigationTitle("Locations")
//        }
//    }
//}
//
//// MARK: - SwiftUI Preview
//struct LocationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationsView()
//    }
//}
//
