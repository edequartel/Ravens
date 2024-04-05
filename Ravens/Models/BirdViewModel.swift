//
//  BirdViewModel.swift
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
    @Published var birds = [Bird]()
    
    var settings: Settings
    init(settings: Settings) {
        self.settings = settings
    }
    
    func fetchData(language: String, for groupID: Int) {
        log.info("fetchData SpeciesViewModel \(groupID)")
        
        let url = settings.endPoint()+"region-lists/\(groupID)/species/"

        log.info("url \(url)")
        log.info("language \(settings.selectedLanguage)")
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": language
        ]

        AF.request(url, headers: headers).responseDecodable(of: [Bird].self){ response in
//            log.info(response.debugDescription)
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.birds = try decoder.decode([Bird].self, from: response.data!)
                } catch {
                    self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error SpeciesViewModel fetching data: \(error)")
            }
        }
    }
}

