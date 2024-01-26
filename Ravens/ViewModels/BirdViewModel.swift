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

    func fetchData(for groupID: Int) {
        log.error("fetchData BirdViewModel \(groupID)")
        let url = "https://waarneming.nl/api/v1/region-lists/\(groupID)/species/"
        
//        let url = "https://waarneming.nl/api/v1/region-lists/5001/species/" //??edq bug
        
        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]
        

        // Use Alamofire to make the API request
        AF.request(url, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                do {
                    // Decode the JSON response into an array of Bird objects
                    let decoder = JSONDecoder()
                    self.birds = try decoder.decode([Bird].self, from: response.data!)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}

