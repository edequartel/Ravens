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
    
//    var minLatitude: Double = 0
//    var maxLatitude: Double = 0
//    var minLongitude: Double = 0
//    var maxLongitude: Double = 0
    
    var locations = [Location]()
    var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
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
        var coordinates: [CLLocationCoordinate2D] = []
        
        let max = (observationsSpecies?.results.count ?? 0)
        for i in 0 ..< max {
            let latitude = observationsSpecies?.results[i].point.coordinates[0] ?? 52.024052
            let longitude = observationsSpecies?.results[i].point.coordinates[1] ?? 5.245350
            coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }

        let minLatitude = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude ?? 0
        let maxLatitude = coordinates.max(by: { $0.latitude > $1.latitude })?.latitude ?? 0
        
        let minLongitude = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude ?? 0
        let maxLongitude = coordinates.max(by: { $0.longitude > $1.longitude })?.longitude ?? 0
        
//        print("\(minLatitude) \(maxLatitude) \(minLongitude) \(maxLongitude)")
        //min 5.238430023193359
        //max 5.250708016753912
        
        //min 52.021517620396565
        //max 52.02693733156565

        let latitudeDelta = 5.250708016753912 - 5.238430023193359
        let longitudeDelta = 52.02693733156565 - 52.021517620396565
        
//        let latitudeDelta = maxLatitude - minLatitude
//        let longitudeDelta = maxLongitude - minLongitude
        
        print("delta \(latitudeDelta) \(longitudeDelta)")

        span = Span(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    

    func fetchData(locationId: Int, limit: Int, offset: Int) {
        log.error("fetchData ObservationsLocationViewModel limit: \(locationId) \(limit) offset: \(offset)")
        
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": settings.selectedLanguage
        ]

        let url = settings.endPoint() + "locations/\(locationId)/observations/"//+"?limit=\(limit)&offset=\(offset)"
        
        log.error(">>> \(url)")

        AF.request(url, headers: headers).responseString { response in
//            print(response.value)
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

