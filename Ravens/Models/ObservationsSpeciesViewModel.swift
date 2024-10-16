//
//  ObservationsSpeciesViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

class ObservationsSpeciesViewModel: ObservableObject {
    let log = SwiftyBeaver.self

    @Published var observationsSpecies: Observations?
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var locations = [Location]()
    
    var settings: Settings
    init(settings: Settings) {
        log.info("init ObservationsSpeciesViewModel")
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
            let hasPhoto = (observationsSpecies?.results[i].photos?.count ?? 0 > 0)
            let hasSound = (observationsSpecies?.results[i].sounds?.count ?? 0 > 0)
            
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity, hasPhoto: hasPhoto, hasSound: hasSound)

            locations.append(newLocation)

        }
    }
    
    func fetchData(speciesId: Int, limit: Int, offset: Int, date: Date, days: Int) {
        log.info("fetchData ObservationsSpeciesViewModel - speciesID \(speciesId)")
        keyChainViewModel.retrieveCredentials()
        
        self.observationsSpecies?.results.removeAll() //?? deze vrijdag voor de vakantie gewijzigd
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": settings.selectedLanguage
        ]

        let date_after = formatCurrentDate(value: Calendar.current.date(byAdding: .day, value: -days, to: date)!)
        let date_before = formatCurrentDate(value: date)
        
        let url = settings.endPoint() + "species/\(speciesId)/observations/?date_after=\(date_after)&date_before=\(date_before)&limit=\(limit)&offset=\(offset)"
        
        log.info("\(url)")

        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observationsSpecies = try decoder.decode(Observations.self, from: data)

                        DispatchQueue.main.async {
                            self.observationsSpecies = observationsSpecies
                            self.getLocations()
                        }
                    } catch {
                        self.log.error("Error ObservationsSpeciesViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsSpeciesViewModel: \(error)")
            }
        }
    }

}
