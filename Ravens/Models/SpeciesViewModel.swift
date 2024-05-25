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
    
    var settings: Settings
    init(settings: Settings) {
        self.settings = settings
        log.error(">>>> SpeciesViewModel init \(settings.selectedLanguage) \(settings.selectedGroup)")
//        fetchData(language: settings.selectedLanguage, for: settings.selectedGroup)
        fetchData(language: "en", for: 5001) //deze aanpassen zie ook de 5001 
    }
    
    func fetchData(language: String, for groupID: Int) {
        log.error(">>>> fetchData SpeciesViewModel \(groupID)")
        
        let url = settings.endPoint()+"region-lists/\(groupID)/species/"

        log.info("url \(url)")
        log.info("language \(settings.selectedLanguage)")
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
//            log.info(response.debugDescription)
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Species objects
                    let decoder = JSONDecoder()
                    self.species = try decoder.decode([Species].self, from: response.data!)
                } catch {
                    self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesViewModel fetching data: \(error)")
            }
        }
    }
    
    func findSpeciesByID(speciesID: Int) -> Species? {
        log.info("findSpeciesByID \(speciesID)")
        for i in 0 ..< species.count {
            if species[i].id == speciesID {
                return species[i]
            }
        }
        return nil
    }
    
}

