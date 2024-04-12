//
//  ObservationsUserViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

class ObservationsUserViewModel: ObservableObject {
    let log = SwiftyBeaver.self

    @Published var observations: Observations?
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var locations = [Location]()
    
    var settings: Settings
    init(settings: Settings) {
        log.info("init ObservationsUserViewModel")
        self.settings = settings

    }

    func getLocations() {
        locations.removeAll()
        
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observations?.results[i].rarity ?? 0
            let hasPhoto = (observations?.results[i].photos?.count ?? 0 > 0)
            let hasSound = (observations?.results[i].sounds?.count ?? 0 > 0)
            
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity, hasPhoto: hasPhoto, hasSound: hasSound)

            locations.append(newLocation)
        }
    }
    

    func fetchData(limit: Int, offset: Int) {
        log.error("fetchData ObservationsUserViewModel limit: \(limit) offset: \(offset)")
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": settings.selectedLanguage
        ]

        let url = settings.endPoint() + "user/observations/"+"?limit=\(limit)&offset=\(offset)"  // /?date_after=\(date_after)&date_before=\(date_before)&limit=\(limit)"
        
        log.error("\(url)")

        AF.request(url, headers: headers).responseString { response in
//            print(response.value)
            switch response.result {
            case .success(let stringResponse):
                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observations = try decoder.decode(Observations.self, from: data)

                        DispatchQueue.main.async {
                            self.observations = observations
                            self.getLocations()
                        }
                    } catch {
                        self.log.error("Error ObservationsUserViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsUserViewModel: \(error)")
            }
        }
    }
}

