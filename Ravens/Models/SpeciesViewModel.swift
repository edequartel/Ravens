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
    
    //hier naar kijken of dit niet beter op language en stored variabele opgeroepen kan worden
//    var settings: Settings
//    init(settings: Settings) {
    init(language: String, regionListId: Int) {
//        self.settings = settings
//        log.error("speciesViewModel init \(settings.selectedLanguageStored) \(settings.selectedRegionListIdStored)")
//        fetchData(language: settings.selectedLanguage, for: settings.selectedRegionListIdStored)
        fetchData(language: language, for: regionListId)
    }
    
//    func fetchData(language: String, for groupID: Int) {
    func fetchData(language: String, for groupID: Int) {
        log.error("SpeciesViewModel fetchData \(language) groupID \(groupID)")

        //        let url = settings.endPoint()+"region-lists/\(groupID)/species/"
        let url = endPoint+"region-lists/\(groupID)/species/"

        log.error("speciesViewModel url \(url)")
        log.error("speciesViewModellanguage \(language) groupID \(groupID)")
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
//            print(response.debugDescription)
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
                self.log.error("---->Error SpeciesViewModel fetching data \(url) \(error)")
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

