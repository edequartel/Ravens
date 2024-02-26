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


class BirdViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var birds = [Bird]()
    
    var settings: Settings
    init(settings: Settings) {
        self.settings = settings
    }
    
    func fetchData(for groupID: Int) {
        log.info("fetchData BirdViewModel should be 5001 for birds but is \(groupID)")
        
        let url = endPoint+"region-lists/\(groupID)/species/"

        log.info("url \(url)")
        log.info("bird view  model --->> language \(settings.selectedLanguage)")
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": settings.selectedLanguage
        ]
        
        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseJSON { response in
//            self.log.info(response.debugDescription)
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.birds = try decoder.decode([Bird].self, from: response.data!)
                } catch {
                    self.log.error("Error BirdViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error BirdViewModel fetching data: \(error)")
            }
        }
    }
}

