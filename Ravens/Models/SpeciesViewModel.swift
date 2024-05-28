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
    
    init(settings: Settings, primary: Bool) {
        print("\(settings.selectedLanguageStored) \(settings.selectedRegionListIdStored)")
        print("\(settings.selectedSecondLanguageStored) \(settings.selectedRegionListIdStored)")
        if primary {
            fetchData(language: settings.selectedLanguageStored, for: settings.selectedRegionListIdStored)
        } else {
            fetchData(language: settings.selectedSecondLanguageStored, for: settings.selectedRegionListIdStored)
        }
    }
    
    func fetchData(language: String, for regionListId: Int) {
        print("*")
        log.error("SpeciesViewModel fetchData \(language) groupID \(regionListId)")

        //        let url = settings.endPoint()+"region-lists/\(groupID)/species/"
        let url = endPoint+"region-lists/\(regionListId)/species/"

//        log.error("speciesViewModel url \(url)")
//        log.error("speciesViewModellanguage \(language) regionListId \(regionListId)")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
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
                    print("-> \(self.species[0].name)")
                } catch {
                    self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesViewModel fetching data \(url) \(error)")
            }
        }
    }
    
    func findSpeciesByID(speciesID: Int) -> Species? {
//        log.error("---->>>> findSpeciesByID \(speciesID)")
        for i in 0 ..< species.count {
//            print("species.name \(species[i].name)")
            if species[i].id == speciesID {
//                print("species.name \(species[i].name) \(species[i].id)")
                return species[i]
            }
        }
        return nil
    }
    
}

