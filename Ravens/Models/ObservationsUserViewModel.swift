//
//  ObservationsUserViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver
import SwiftUI
import SVGView

class window: ObservableObject {
    @Published var maximum = 123
    @Published var offset = 15
    @Published var value = 0

    func next() {
        if value + offset > maximum {
            value = maximum
        } else {
            value = value + offset
        }
    }
    
    func previous() {
        let remainder = value % offset
        if remainder != 0 {
            value = value - remainder
        } else if value - offset < 0 {
            value = 0
        } else {
            value = value - offset
        }
    }
}
//to test
struct WindowView: View {
    @ObservedObject var windowObject = window()
    
    var body: some View {
        VStack {
            Text("Value: \(windowObject.value)")
            ZStack {
                SVGView(contentsOf: Bundle.main.url(forResource: "plus-square", withExtension: "svg")!)
                    .frame(width: 16, height: 16, alignment: .bottomTrailing)
                    .foregroundColor(.green)
                
                SVGView(contentsOf: Bundle.main.url(forResource: "w_wikipedia", withExtension: "svg")!)
                    .frame(width: 64, height: 64, alignment: .center)
                    .foregroundColor(.green)
            }
            
            
            Button(action: {
                self.windowObject.next()
            }) {
                Text("Next")
            }

            Button(action: {
                self.windowObject.previous()
            }) {
                Text("Previous")
            }
        }
    }
}

class ObservationsUserViewModel: ObservableObject {
    let log = SwiftyBeaver.self

    @Published var observations: Observations?
    
    @Published var limit = 100
    @Published var offset = 0
    @Published var maxOffset = 200 //??
    @Published var start = 0
    @Published var end = 100
    
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var locations = [Location]()
    
    func getLocations() {
        locations.removeAll()
        
        let max = (observations?.results.count ?? 0)
        for i in 0 ..< max {
 
            let name = observations?.results[i].species_detail.name ?? "Unknown name"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350
            let rarity = observations?.results[i].rarity ?? 0
            let hasPhoto = (observations?.results[i].photos?.count ?? 0 > 0)
            let hasSound = (observations?.results[i].sounds?.count ?? 0 > 0)
            
            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), rarity: rarity, hasPhoto: hasPhoto, hasSound: hasSound)

            locations.append(newLocation)
        }
    }
    

    func fetchData(language: String, userId: Int, completion: @escaping () -> Void) {
        log.info("fetchData ObservationsUserViewModel userId: \(userId) limit: \(limit) offset: \(offset)")
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": language
        ]

        let url = endPoint() + "user/\(userId)/observations/"+"?limit=\(self.limit)&offset=\(self.offset)" 

        log.error("fetchData ObservationsUserViewModel \(url)")

        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
                // Now you can convert the stringResponse to Data and decode it
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observations = try decoder.decode(Observations.self, from: data)

                        DispatchQueue.main.async {
                            self.observations = observations
                            self.getLocations()
                            completion() // call the completion handler if it exists
                        }
                        
                    } catch {
                        print("\(stringResponse)")
                        self.log.error("Error ObservationsUserViewModel decoding JSON: \(error)")
                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsUserViewModel: \(error)")
            }
        }
    }
}

