//
//  ObsModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/02/2024.
//

import Foundation
import Alamofire
import SwiftyBeaver

class ObsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var observation: Obs? //??

    func fetchData(for obsID: Int, language: String, token: String) {
        
        let url = endPoint+"observations/\(obsID)/"
        
        let headers: HTTPHeaders = [
            "Language" : language,
            "Authorization": "Token " + token
        ]
        
        
        AF.request(url, headers: headers).responseJSON { response in
//            self.log.info(response.debugDescription)
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.observation = try decoder.decode(Obs.self, from: response.data!)
                } catch {
                    self.log.error("Error ObsViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error ObsViewModel fetching data: \(error)")
            }
        }
    }
}
