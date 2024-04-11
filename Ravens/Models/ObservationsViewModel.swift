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
    var hasPhoto: Bool
    var hasSound: Bool
}

struct Span {
    var latitudeDelta: Double
    var longitudeDelta: Double
    var latitude: Double
    var longitude: Double
}

class ObservationsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observations: Observations?
    
    var locations = [Location]()

    var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1, latitude: 52.024052, longitude: 5.245350)
    
//    var settings: Settings
//    init(settings: Settings) {
//        log.info("init ObservationsViewModel")
//        self.settings = settings
//    }

    func getLocations() {
        locations.removeAll()
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observations?.results[i].rarity ?? 0
            let hasPhoto = observations?.results[i].has_photo ?? false
            let hasSound = observations?.results[i].has_sound ?? false
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity, hasPhoto: hasPhoto, hasSound: hasSound)
            locations.append(newLocation)
        }
    }

    func getSpan() {
        var latitudes: [Double] = []
        var longitudes: [Double] = []
        
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            latitudes.append(latitude)
            longitudes.append(longitude)
        }
        let minLatitude = latitudes.min() ?? 0
        let maxLatitude = latitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        let centreLatitude = (minLatitude + maxLatitude) / 2
        let centreLongitude = (minLongitude + maxLongitude) / 2
        let latitudeDelta = (maxLatitude - minLatitude) * 1.7
        let longitudeDelta = (maxLongitude - minLongitude) * 1.7

        span = Span(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta, latitude: centreLatitude, longitude: centreLongitude)
    }
    
    func fetchData(lat: Double, long: Double, settings: Settings, completion: @escaping () -> Void) {
        log.info("fetchData ObservationsViewModel")

        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]
        
        let url = settings.endPoint()+"observations/around-point/?days=\(settings.days)&end_date=\(formatCurrentDate(value: settings.selectedDate))&lat=\(lat)&lng=\(long)&radius=\(settings.radius)&species_group=\(settings.selectedGroupId)&min_rarity=\(settings.selectedRarity)"
        
//        if !settings.infinity {
//            url = url + "&date_after=\(date_after)&date_before=\(date_before)"
//        }
        
        log.error("ObservationsViewModel \(url)")
        
        AF.request(url, headers: headers).responseDecodable(of: Observations.self) { response in
            switch response.result {
            case .success(let observations):
                DispatchQueue.main.async {
                    self.observations = observations
                    self.getLocations()
                    self.getSpan()
                    self.log.info("observations locations count \(self.locations.count)")
                    completion()
                }
            case .failure(let error):
                self.log.error("Error ObservationsViewModel: \(error)")
            }
        }
        
    }
}

