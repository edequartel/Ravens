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
import SwiftyBeaver

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
    let log = SwiftyBeaver.self
    
    @Published var POIs = [POI]()
    
    init() {
        fetchPOIs()
    }

//    func fetchPOIs(completion: @escaping () -> Void = {}) {
    func fetchPOIs() {
        // Try to load from local JSON file
        if let localData = self.loadJsonFromFile() {
            let decoder = JSONDecoder()
            if let POIs = try? decoder.decode(POIList.self, from: localData) {
                self.POIs = POIs.poi
//                completion()
        
            }
            return
        }
    }

    private func loadJsonFromFile() -> Data? {
        if let path = Bundle.main.path(forResource: "poi", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                log.error("Error loading file: \(error.localizedDescription)")
            }
        } else {
            log.error("File poi.json not found in app bundle.")
        }
        return nil
    }
}
