//
//  GeoJSONViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import Foundation
import Alamofire
import MapKit

class GeoJSONViewModel: ObservableObject {
    var polyOverlays = [MKPolygon]()

    func fetchGeoJsonData(for locationID: String,  completion: @escaping ([MKPolygon]) -> Void) {
        let apiUrl = "https://waarneming.nl/api/v1/locations/geojson/?id=\(locationID)"
        print(apiUrl)
        
        AF.request(apiUrl).responseData { response in
            switch response.result {
            case .success(let value):
                    if let data = try? JSONSerialization.jsonObject(with: value),
                       let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let geoJSON = try? MKGeoJSONDecoder().decode(jsonData) {
                        self.polyOverlays =  self.parseGeoJSON(geoJSON)
                        completion(self.polyOverlays)
                    }
            case .failure(let error):
                print("Error fetching data: \(error)")
                    
            }
        }
    }
    
    func parseGeoJSON(_ geoJSON: [MKGeoJSONObject])->[MKPolygon] {
        var overlays = [MKPolygon]()
        for item in geoJSON {
            if let feature = item as? MKGeoJSONFeature {
                for geo in feature.geometry {
                    if let polygon = geo as? MKPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
        return overlays
    }
}

//class GeoJSONViewModel: ObservableObject {
//    @Published var polyOverlays = [MKPolygon]()
//
//    func fetchGeoJsonData(for locationID: String) {
//        let apiUrl = "https://waarneming.nl/api/v1/locations/geojson/?id=\(locationID)"
//        print(apiUrl)
//        
//        AF.request(apiUrl).responseData { response in
//            switch response.result {
//            case .success(let value):
//                    if let data = try? JSONSerialization.jsonObject(with: value),
//                       let jsonData = try? JSONSerialization.data(withJSONObject: data),
//                       let geoJSON = try? MKGeoJSONDecoder().decode(jsonData) {
//                        self.polyOverlays =  self.parseGeoJSON(geoJSON)
//                    }
//            case .failure(let error):
//                print("Error fetching data: \(error)")
//                    
//            }
//        }
//    }
//    
//    func parseGeoJSON(_ geoJSON: [MKGeoJSONObject])->[MKPolygon] {
//        var overlays = [MKPolygon]()
//        for item in geoJSON {
//            if let feature = item as? MKGeoJSONFeature {
//                for geo in feature.geometry {
//                    if let polygon = geo as? MKPolygon {
//                        overlays.append(polygon)
//                    }
//                }
//            }
//        }
//        return overlays
//    }
//}
