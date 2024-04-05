//
//  GeoJSONViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

class GeoJSONViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    var polyOverlays = [MKPolygon]()
    
    var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1, latitude: 52.024052, longitude: 5.245350)

    func fetchGeoJsonData(for locationID: String,  completion: @escaping ([MKPolygon]) -> Void) {
        let apiUrl = "https://waarneming.nl/api/v1/locations/geojson/?id=\(locationID)"
        log.info(apiUrl)
        AF.request(apiUrl).responseData { response in
            switch response.result {
            case .success(let value):
                    if let data = try? JSONSerialization.jsonObject(with: value),
                       let jsonData = try? JSONSerialization.data(withJSONObject: data),
                       let geoJSON = try? MKGeoJSONDecoder().decode(jsonData) {
                        self.polyOverlays =  self.parseGeoJSON(geoJSON)
                        self.getSpan()
                        completion(self.polyOverlays)
                    }
            case .failure(let error):
                self.log.error("Error fetching data: \(error)")
                    
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
    
    //span
    func getSpan() {
        var minLat = CLLocationDegrees(MAXFLOAT)
        var maxLat = -CLLocationDegrees(MAXFLOAT)
        var minLon = CLLocationDegrees(MAXFLOAT)
        var maxLon = -CLLocationDegrees(MAXFLOAT)
        print(polyOverlays.count)
        for polygon in polyOverlays {
            let points = polygon.points()
            for i in 0..<polygon.pointCount {
                let coordinate = points[i].coordinate
                            minLat = min(minLat, coordinate.latitude)
                            maxLat = max(maxLat, coordinate.latitude)
                            minLon = min(minLon, coordinate.longitude)
                            maxLon = max(maxLon, coordinate.longitude)
                        }
            span.latitude = (maxLat + minLat) / 2
            span.longitude = (maxLon +  minLon) / 2
            span.latitudeDelta = (maxLat - minLat) * 1.1
            span.longitudeDelta = (maxLon - minLon) * 1.1
        }
    }
}

