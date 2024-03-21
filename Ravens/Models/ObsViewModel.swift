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
    
    @Published var observation: Obs?
    
    private var lastRequestTime: Date? //
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var settings: Settings
    init(settings: Settings) {
        log.debug("init ObsViewModel")
        self.settings = settings
    }
    
    func fetchData(for obsID: Int) {
        log.info("fetchData for ObsViewModel \(obsID) at \(Date())")
        
        let url = settings.endPoint()+"observations/\(obsID)/"
        
        keyChainViewModel.retrieveCredentials()
        
        let headers: HTTPHeaders = [
            "Accept-Language" : settings.selectedLanguage,
            "Authorization": "Token " + keyChainViewModel.token //settings.tokenKey
        ]
        
        log.info("\(url) \(headers)")
                  
        AF.request(url, headers: headers).responseDecodable(of: Obs.self) {
            response in
            //
//            self.log.error(response.debugDescription)
            self.log.info("Making request for obsID \(obsID) at \(Date())")
            //
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
                //
                self.log.error("Error ObsViewModel fetching data; \(error)")
            }
        }
    }
}

