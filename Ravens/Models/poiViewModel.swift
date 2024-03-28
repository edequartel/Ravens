//
//  poi.swift
//  Ravens
//
//  Created by Eric de Quartel on 28/03/2024.
//

import Alamofire
import Foundation
import SwiftUI
import MapKit

struct POI: Decodable {
    let name: String
    let coordinate: Coordinate
}

struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double
    
    var cllocationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct POIList: Decodable {
    let poi: [POI]
}

class POIViewModel: ObservableObject {
    @Published var poiList = [POI]()

    func fetchPOIs() {
        // Try to load from local JSON file
        if let localData = self.loadJsonFromFile() {
//            print("JSON data: \(String(data: localData, encoding: .utf8) ?? "Unable to format data as string")")
            let decoder = JSONDecoder()
            if let poiList = try? decoder.decode(POIList.self, from: localData) {
//                print("Decoded POIList: \(poiList)")
                self.poiList = poiList.poi
//                print(poiList.poi)
            }
            return
        }

//        // Otherwise, fetch from network
//        AF.request("https://api.example.com/poi").responseDecodable(of: POIList.self) { response in
//            switch response.result {
//            case .success(let poiList):
//                DispatchQueue.main.async {
//                    self.poiList = poiList.poi
//                }
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
    }

    private func loadJsonFromFile() -> Data? {
        if let path = Bundle.main.path(forResource: "poi", ofType: "json") {
            do {
//                print("File poi.json FOUND in app bundle.")
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                // handle error
                print("Error loading file: \(error.localizedDescription)")
            }
        } else {
//            print("File poi.json not found in app bundle.")
        }
        return nil
    }
}
