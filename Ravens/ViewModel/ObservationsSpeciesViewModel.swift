////DEPRICIATED
////  ObservationsSpeciesViewModel.swift
////  Ravens
////
////  Created by Eric de Quartel on 18/01/2024.
////
//
//import Foundation
//import Alamofire
//import MapKit
//import SwiftyBeaver
//
//class ObservationsSpeciesViewModel: ObservableObject {
//    let log = SwiftyBeaver.self
//
//    @Published var observationsSpecies: Observations?
//
//    private var keyChainViewModel =  KeychainViewModel()
//
//    var locations = [Location]()
//
//    func getLocations() {
//        locations.removeAll()
//
//        let max = (observationsSpecies?.results.count ?? 0)
//        for index in 0 ..< max {
//
//            let name = observationsSpecies?.results[index].speciesDetail.name ?? "Unknown name"
//            let latitude = observationsSpecies?.results[index].point.coordinates[1] ?? 52.024052
//            let longitude = observationsSpecies?.results[index].point.coordinates[0] ?? 5.245350
//            let rarity = observationsSpecies?.results[index].rarity ?? 0
//            let hasPhoto = (observationsSpecies?.results[index].photos?.count ?? 0 > 0)
//            let hasSound = (observationsSpecies?.results[index].sounds?.count ?? 0 > 0)
//
//            let newLocation = Location(
//              name: name,
//              coordinate: CLLocationCoordinate2D(
//                latitude: latitude,
//                longitude: longitude),
//              rarity: rarity,
//              hasPhoto: hasPhoto,
//              hasSound: hasSound)
//            locations.append(newLocation)
//        }
//    }
//
//    func fetchData(settings: Settings, speciesId: Int, limit: Int, offset: Int, completion: (() -> Void)? = nil) {
//        log.error("fetchData ObservationsSpeciesViewModel - speciesID \(speciesId)")
//        keyChainViewModel.retrieveCredentials()
//
//        self.observationsSpecies?.results.removeAll()
//
//        // Add the custom header
//        let headers: HTTPHeaders = [
//            "Authorization": "Token "+keyChainViewModel.token,
//            "Accept-Language": settings.selectedLanguage
//        ]
//
//        let dateAfter = formatCurrentDate(
//          value: Calendar.current.date(byAdding: .day, value: -14, to: settings.selectedDate)!)
//        let dateBefore = formatCurrentDate(value: settings.selectedDate)
//
//        let url = endPoint(value: settings.selectedInBetween) + "species/\(speciesId)/observations/?date_after=\(dateAfter)&date_before=\(dateBefore)&limit=\(limit)&offset=\(offset)"        
////      let url = endPoint(value: settings.selectedInBetween) + "species/\(speciesId)/observations/?limit=\(limit)&offset=\(offset)"
//
//        log.error("\(url)")
//
//        AF.request(url, headers: headers).responseString { response in
//            switch response.result {
//            case .success(let stringResponse):
//                // Now you can convert the stringResponse to Data and decode it
//                if let data = stringResponse.data(using: .utf8) {
//                    do {
//                        let decoder = JSONDecoder()
//                        let observationsSpecies = try decoder.decode(Observations.self, from: data)
//
//                        DispatchQueue.main.async {
//                            self.observationsSpecies = observationsSpecies
//                            self.getTimeData() 
//                            self.getLocations()
//                          
//                            completion?() // call the completion handler if it exists
//                        }
//
//                    } catch {
//                        self.log.error("Error ObservationsSpeciesViewModel decoding JSON: \(error)")
//                        self.log.error("\(url)")
//                    }
//                }
//            case .failure(let error):
//                self.log.info("Error ObservationsSpeciesViewModel: \(error)")
//            }
//        }
//    }
//
//
//  func getTimeData() {
//    let max = (observationsSpecies?.results.count ?? 0)
//    for index in 0..<max {
//      if let date = observationsSpecies?.results[index].date,
//         let time = observationsSpecies?.results[index].time {
//
//        // Concatenate date and time strings
//        let timeDateStr = date + " " + time
//
//        // Date formatter to parse the concatenated date and time string
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//
//        // Convert the concatenated string back to a Date
//        if let formattedDate = dateFormatter.date(from: timeDateStr) {
//          observationsSpecies?.results[index].timeDate = formattedDate
//        } else {
//          // Handle error if the date string could not be parsed
//          log.info("Error: Could not parse date string \(timeDateStr)")
//        }
//      } else {
//        // Handle the case where either the date or time is nil
//        log.info("Error: Missing date or time for index \(index)")
//      }
//    }
//  }
//}
