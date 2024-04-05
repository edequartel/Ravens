//
//  ObservationsLocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//


import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

class ObservationsLocationViewModel: ObservableObject {
    let log = SwiftyBeaver.self

    @Published var observationsSpecies: ObservationsSpecies?
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var locations = [Location]()
    var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1, latitude: 0, longitude: 0)
    
    var settings: Settings
    init(settings: Settings) {
        log.info("init ObservationsLocationViewModel")
        self.settings = settings

    }

    func getLocations() {
        locations.removeAll()
        
        let max = (observationsSpecies?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observationsSpecies?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observationsSpecies?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observationsSpecies?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observationsSpecies?.results[i].rarity ?? 0
            let hasPhoto = (observationsSpecies?.results[i].photos.count ?? 0 > 0)
            let hasSound = (observationsSpecies?.results[i].sounds.count ?? 0 > 0)
            
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity, hasPhoto: hasPhoto, hasSound: hasSound)

            locations.append(newLocation)
        }
    }
    
    func getSpan() {
        var latitudes: [Double] = []
        var longitudes: [Double] = []
        
        let max = (observationsSpecies?.results.count ?? 0)
        for i in 0 ..< max {
            let longitude = observationsSpecies?.results[i].point.coordinates[0] ?? 52.024052
            let latitude = observationsSpecies?.results[i].point.coordinates[1] ?? 5.245350
            latitudes.append(latitude)
            longitudes.append(longitude)
        }
        
        let minLatitude = latitudes.min() ?? 0
        let maxLatitude = latitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        
        let centreLatitude = (minLatitude + maxLatitude) / 2
        let centreLongitude = (minLongitude + maxLongitude) / 2
        
        let latitudeDelta = (maxLatitude - minLatitude) * 1.5
        let longitudeDelta = (maxLongitude - minLongitude) * 1.5

        span = Span(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta, latitude: centreLatitude, longitude: centreLongitude)
    }
    

    func fetchData(locationId: Int, limit: Int, offset: Int, completion: @escaping () -> Void) {
        log.info("fetchData ObservationsLocationViewModel limit: \(locationId) \(limit) offset: \(offset)")
        
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "authorization": "Token "+keyChainViewModel.token,
            "accept-Language": settings.selectedLanguage,
        ]
        
        let date_after = formatCurrentDate(value: Calendar.current.date(byAdding: .day, value: -settings.days, to: settings.selectedDate)!)
        let date_before = formatCurrentDate(value: settings.selectedDate)
        
        
        var url = settings.endPoint() + "locations/\(locationId)/observations/"+"?species_group=\(settings.selectedGroupId)"
        if !settings.infinity {
            url = url + "&date_after=\(date_after)&date_before=\(date_before)"
        }
        
        log.info("URL \(url)")
//        log.error("headers \(headers)")

        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observationsSpecies = try decoder.decode(ObservationsSpecies.self, from: data)

                        DispatchQueue.main.async {
                            self.observationsSpecies = observationsSpecies
                            self.getLocations()
                            self.getSpan()
                            completion()
                        }
                    } catch {
                        self.log.error("Error ObservationsLocationViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsLocationViewModel: \(error)")
            }
        }
    }
}

