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
    
    func fetchData(settings: Settings, speciesId: Int, limit: Int, offset: Int, completion: (() -> Void)? = nil) {
        log.error("fetchData ObservationsSpeciesViewModel - speciesID \(speciesId)")
        keyChainViewModel.retrieveCredentials()
        
        self.observationsSpecies?.results.removeAll()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": settings.selectedLanguage
        ]

        let date_after = formatCurrentDate(value: Calendar.current.date(byAdding: .day, value: -14, to: settings.selectedDate)!)
        let date_before = formatCurrentDate(value: settings.selectedDate)
        
        let url = endPoint(value: settings.selectedInBetween) + "species/\(speciesId)/observations/?date_after=\(date_after)&date_before=\(date_before)&limit=\(limit)&offset=\(offset)"
        
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
                            completion?() // call the completion handler if it exists
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
