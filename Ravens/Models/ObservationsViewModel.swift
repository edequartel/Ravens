//
//  ObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var rarity: Int
}

class ObservationsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observations: Observations?
    
    var locations = [Location]()
    var poiLocations = [Location]()
    
    var settings: Settings
    init(settings: Settings) {
        log.info("init ObservationsViewModel")
        self.settings = settings

    }

    ///
    func getLocations() {
        locations.removeAll()
        
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observations?.results[i].rarity ?? 0
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
        newLocation = Location(name: "De zouweboezem", coordinate: CLLocationCoordinate2D(latitude: 51.849150, longitude: 4.983150), rarity: 0)
        poiLocations.append(newLocation)        
        newLocation = Location(name: "Werkhoven", coordinate: CLLocationCoordinate2D(latitude: 52.024052, longitude: 5.245350), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Blauwe kamer", coordinate: CLLocationCoordinate2D(latitude: 51.942360, longitude: 5.610475), rarity: 0)
        poiLocations.append(newLocation)
        newLocation = Location(name: "Steenwaard", coordinate: CLLocationCoordinate2D(latitude: 51.965423, longitude: 5.215302), rarity: 0)
        poiLocations.append(newLocation)
        
        
        
        
//
//        newLocation = Location(name: "De groene Jonker", coordinate: CLLocationCoordinate2D(latitude: 52.180458, longitude: 4.825451), rarity: 0)
//        poiLocations.append(newLocation)
        
        

    }
    
    ///
    func fetchData(lat: Double, long: Double) {
        log.info("fetchData ObservationsViewModel")

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]
        
        let url = settings.endPoint()+"observations/around-point/?days=\(settings.days)&end_date=\(formatCurrentDate(value: settings.selectedDate))&lat=\(lat)&lng=\(long)&radius=\(settings.radius)&species_group=\(settings.selectedGroupId)&min_rarity=\(settings.selectedRarity)"
        
        log.info("\(url)")
        
        AF.request(url, headers: headers).responseDecodable(of: Observations.self) { response in
            switch response.result {
            case .success(let observations):
                DispatchQueue.main.async {
                    self.observations = observations
                    self.getLocations()
                    self.getPoiLocations()
                    self.log.info("observations locations count \(self.locations.count)")
                }
            case .failure(let error):
                self.log.error("Error ObservationsViewModel: \(error)")
            }
        }
        
    }
}
