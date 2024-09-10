//
//  SpeciesViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//
// View Model

import Foundation
import Alamofire
import SwiftyBeaver


class SpeciesViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var species = [Species]()
    @Published var speciesSecondLanguage = [Species]()
    
    func fetchDataFirst(settings: Settings, completion: (() -> Void)? = nil) {
        log.info("SpeciesViewModel fetchDataFirst \(settings.selectedLanguage) groupID \(settings.selectedRegionListId)")
        let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"

        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]

        AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
            // Check if response data exists
            if let data = response.data {
                // Convert data to String and print
                let str = String(data: data, encoding: .utf8)
                self.log.verbose(str ?? "No data")
            }

            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Species objects
                    let decoder = JSONDecoder()
                    self.species = try decoder.decode([Species].self, from: response.data!)
                    completion?() // call the completion handler if it exists
                } catch {
                    self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesViewModel fetching data \(url) \(error)")
            }
        }
    }
    
    func fetchDataSecondLanguage(settings: Settings, completion: (() -> Void)? = nil) {
        log.info("SpeciesViewModel fetchDataSecondLanguage \(settings.selectedSecondLanguage) groupID \(settings.selectedRegionListId)")

        let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedSecondLanguage
        ]

        AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
            // Check if response data exists
            if let data = response.data {
                // Convert data to String and print
                let str = String(data: data, encoding: .utf8)
                self.log.verbose(str ?? "No data")
            }

            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Species objects
                    let decoder = JSONDecoder()
                    self.speciesSecondLanguage = try decoder.decode([Species].self, from: response.data!)
                    completion?() // call the completion handler if it exists
                } catch {
                    self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesViewModel fetching data \(url) \(error)")
            }
        }
    }
    
//    func findSpeciesByID(speciesID: Int) -> Species? {
    func findSpeciesByID(speciesID: Int) -> String? {
        guard let index = species.firstIndex(where: { $0.id == speciesID }) else {
            return nil
        }
        
        // Check if index is within the range of speciesSecondLanguage array
        guard index < speciesSecondLanguage.count else {
            print("Index is out of range")
            return nil
        }

        return speciesSecondLanguage[index].name
    }
}

