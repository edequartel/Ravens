//
//  ObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation
import Alamofire
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var rarity: Int
}

class ObservationsViewModel: ObservableObject {
    @Published var observations: Observations?
    
    var locations = [Location]()
    var poiLocations = [Location]()
    
    ///
    func getLocations() {
        locations.removeAll()
        
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observations?.results[i].rarity ?? 1
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity)

            locations.append(newLocation)

        }
    }
   
    func getPoiLocations() {
        poiLocations.removeAll()
        var newLocation = Location(name: "IJmuiden", coordinate: CLLocationCoordinate2D(latitude: 52.459402, longitude:  4.540332), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Oostvaardersplassen", coordinate: CLLocationCoordinate2D(latitude: 52.452926, longitude: 5.357325), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Brouwersdam", coordinate: CLLocationCoordinate2D(latitude: 51.761799, longitude: 3.853920), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Mokbaai", coordinate: CLLocationCoordinate2D(latitude: 53.005861, longitude: 4.762873), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "De groene Jonker", coordinate: CLLocationCoordinate2D(latitude: 52.180458, longitude: 4.825451), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Lauwersoog", coordinate: CLLocationCoordinate2D(latitude: 53.381690, longitude: 6.188163), rarity: 0)
        poiLocations.append(newLocation)
        
//        newLocation = Location(name: "De Kraaijenbergse Plassen", coordinate: CLLocationCoordinate2D(latitude: 52.180458, longitude: 4.825451), rarity: 0)
//        poiLocations.append(newLocation)
//        
//        newLocation = Location(name: "De groen Jonker", coordinate: CLLocationCoordinate2D(latitude: 52.180458, longitude: 4.825451), rarity: 0)
//        poiLocations.append(newLocation)
        
        

    }
    
    ///
    func fetchData(days: Int, endDate: Date, lat: Double, long: Double, radius: Int, species_group: Int, min_rarity: Int) {
        print("fetchData ObservationsViewModel")

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]
        
        let url = "https://waarneming.nl/api/v1/observations/around-point/?days=\(days)&end_date=\(formatCurrentDate(value: endDate))&lat=\(lat)&lng=\(long)&radius=\(radius)&species_group=\(species_group)&min_rarity=\(min_rarity)"
        
        print("\(url)")
        
        AF.request(url, headers: headers).responseDecodable(of: Observations.self) { response in
            switch response.result {
            case .success(let observations):
                DispatchQueue.main.async {
                    self.observations = observations
                    self.getLocations()
                    self.getPoiLocations()
                    print("api locations count \(self.locations.count)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
}
