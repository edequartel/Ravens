//
//  ObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation
import SwiftUI
import Alamofire
import MapKit
import SwiftyBeaver

struct Location: Identifiable {//}, Hashable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var rarity: Int
    var hasPhoto: Bool
    var hasSound: Bool

//    static func == (lhs: Location, rhs: Location) -> Bool {
//        return lhs.id == rhs.id &&
//               lhs.name == rhs.name &&
//               lhs.coordinate.latitude == rhs.coordinate.latitude &&
//               lhs.coordinate.longitude == rhs.coordinate.longitude &&
//               lhs.rarity == rhs.rarity &&
//               lhs.hasPhoto == rhs.hasPhoto &&
//               lhs.hasSound == rhs.hasSound
//    }
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(name)
//        hasher.combine(coordinate.latitude)
//        hasher.combine(coordinate.longitude)
//        hasher.combine(rarity)
//        hasher.combine(hasPhoto)
//        hasher.combine(hasSound)
//    }
}

struct Span {
    var latitudeDelta: Double
    var longitudeDelta: Double
    var latitude: Double
    var longitude: Double
}

class ObservationsRadiusViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observations: Observations?
//    @Published var cameraPosition: MapCameraPosition = .automatic
    
    var locations = [Location]()
    var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1, latitude: 0, longitude: 0)

    func fetchData(settings: Settings, lat: Double, long: Double, completion: @escaping () -> Void = {}) {
        log.error("fetchData ObservationsViewModel")

        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]
        
        let url = endPoint(
            value: settings.selectedInBetween)+"observations/around-point/?days=\(settings.days)&end_date=\(formatCurrentDate(value: settings.selectedDate))&lat=\(lat)&lng=\(long)&radius=\(settings.radius)&species_group=\(settings.selectedSpeciesGroupId)&min_rarity=\(settings.selectedRarity)"
        
        log.info("fetchData ObservationsViewModel url \(url)")
        
        AF.request(url, headers: headers).responseDecodable(of: Observations.self) { response in
            switch response.result {
            case .success(let observations):
                DispatchQueue.main.async {
                    self.observations = observations
                    self.getLocations()
                    self.log.info("observations locations count \(self.locations.count)")
                    
                    completion()
                }
            case .failure(let error):
                self.log.error("Error ObservationsViewModel: \(error)")
            }
        }
    }
    
    func getLocations() {
        locations.removeAll()
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 0
            let longitude = observations?.results[i].point.coordinates[0] ?? 0
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
            let latitude = observations?.results[i].point.coordinates[1] ?? 0
            let longitude = observations?.results[i].point.coordinates[0] ?? 0
            latitudes.append(latitude)
            longitudes.append(longitude)
        }
        let minLatitude = latitudes.min() ?? 0
        let maxLatitude = latitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        let centreLatitude = (minLatitude + maxLatitude) / 2
        let centreLongitude = (minLongitude + maxLongitude) / 2
        let latitudeDelta = (maxLatitude - minLatitude) * 3 //1.7
        let longitudeDelta = (maxLongitude - minLongitude) * 3 //1.7

        span = Span(
            latitudeDelta: latitudeDelta,
            longitudeDelta: longitudeDelta,
            latitude: centreLatitude,
            longitude: centreLongitude
        )
    }
    
    func getCameraPosition() -> MapCameraPosition {
        getSpan()
        let center = CLLocationCoordinate2D(
            latitude: span.latitude,
            longitude: span.longitude)
        
        let span = MKCoordinateSpan(
            latitudeDelta: span.latitudeDelta,
            longitudeDelta: span.longitudeDelta)
        
        
        let region = MKCoordinateRegion(center: center, span: span)
        return MapCameraPosition.region(region)
    }
}

