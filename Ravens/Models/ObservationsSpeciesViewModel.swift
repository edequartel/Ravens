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

    @Published var observationsSpecies: ObservationsSpecies?
    
    var locations = [Location]()

    ///
    func getLocations() {
        locations.removeAll()
        
        let max = (observationsSpecies?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observationsSpecies?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observationsSpecies?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observationsSpecies?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observationsSpecies?.results[i].rarity ?? 0
            
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity)

            locations.append(newLocation)

        }
    }
    
    func fetchData(speciesId: Int, endDate: Date, days: Int, token: String, language: String, limit: Int) {
        log.info("fetchData ObservationsSpeciesViewModel - speciesID \(speciesId)")
        log.info("token ObservationsSpeciesViewModel - speciesID\(token)")

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Authorization": "Token "+token,
            "Accept-Language": "eng" //language  //Accept-Language
        ]

        let date_after = formatCurrentDate(value: Calendar.current.date(byAdding: .day, value: -days, to: endDate)!)
        let date_before = formatCurrentDate(value:endDate)
        
        let url = endPoint+"species/\(speciesId)/observations/?date_after=\(date_after)&date_before=\(date_before)&limit=\(limit)"
        
        log.info("\(url)")

        log.error("headers: \(headers.dictionary)")
        
        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
//                self.log.error("Response as String: \(stringResponse)")

                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observationsSpecies = try decoder.decode(ObservationsSpecies.self, from: data)

                        DispatchQueue.main.async {
                            self.observationsSpecies = observationsSpecies
                            // Continue with your logic
                            self.log.warning("count  \(speciesId) - \(self.observationsSpecies?.count)")
                            self.getLocations()
                           

                            // Check if there is more data to fetch
//                            if observationsSpecies.next != nil {
//                                // Call the fetchData function recursively with the next page
//                                url = observationsSpecies.next ?? ""
//                                self.fetchData(speciesId: speciesId, endDate: endDate, page: page + 1)
//                            }
                        }
                    } catch {
                        self.log.error("Error ObservationsSpeciesViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
//                        self.log.error("\(response.debugDescription)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsSpeciesViewModel: \(error)")
            }
        }
    }

}


//func fetchData(speciesId:Int, endDate: Date) {
//    print("fetchData ObservationsSpeciesViewModel")
//    
//    // Add the custom header 'Accept-Language: nl'
//    let headers: HTTPHeaders = [
//        "Accept-Language": "nl",
//        "Authorization": "Token 21047b0d6742dc36234bc5293053bc757623470b" //<<TOKEN LATER BIJ ZETTEN 3600??
//    ]
//    let date = "2023-01-01"
//    let url = "https://waarneming.nl/api/v1/species/\(speciesId)/observations/?date_after=\(date)" //zwarte stern 32
////        let url = "https://waarneming.nl/api/v1/species/\(speciesId)/observations/?date_after=\(formatCurrentDate(value: endDate))"
//    print("\(url)")
//
//    AF.request(url, headers: headers).responseString { response in
//        switch response.result {
//        case .success(let stringResponse):
//            print("Response as String: \(stringResponse)")
//
//            // Now you can convert the stringResponse to Data and decode it
//            if let data = stringResponse.data(using: .utf8) {
//                do {
//                    let decoder = JSONDecoder()
//                    let observationsSpecies = try decoder.decode(ObservationsSpecies.self, from: data)
//
//                    DispatchQueue.main.async {
//                        self.observationsSpecies = observationsSpecies
//                        // Continue with your logic
//                        self.getLocations()
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            }
//        case .failure(let error):
//            print("Error: \(error)")
//        }
//    }
//
//}
