//
//  UserViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyBeaver

class UserViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var user: UserData?
    
    private var keyChainViewModel =  KeychainViewModel()
    
    func fetchUserData(completion: (() -> Void)? = nil) {
        log.info("fetchUserData")
        
        keyChainViewModel.retrieveCredentials()
        
        // Api Logic
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token
        ]
        let url = endPoint() + "user/info/"
        log.info("UserViewModel \(url)")
        
        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                      
                        self.log.debug("stringResponse: \(stringResponse)")
                        self.user = try JSONDecoder().decode(UserData.self, from: data)
                        self.log.info("UserViewModel user: \(self.user)")
                        completion?() // call the completion handler if it exists
                        
                    } catch {
                        self.log.error("Error UserViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error UserViewModel: \(error)")
            }
        }
    }
}

