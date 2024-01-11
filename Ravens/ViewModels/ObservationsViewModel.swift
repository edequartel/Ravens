//
//  ObservationsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation
import Alamofire
import MapKit

class ObservationsViewModel: ObservableObject {
    @Published var observations: Observations?
    
    func locations()->[Location] {
        var locations = [Location]()
        
        for i in 0..<(observations?.count ?? 0) {
            let newlocation = Location(
                name: (observations?.results[i].species_detail.name ?? "Unknown"),
                coordinate: 
                    CLLocationCoordinate2D(
                        latitude: observations?.results[i].point.coordinates[i] ?? 52.024052,
                        longitude: observations?.results[i].point.coordinates[i] ?? 5.2
                    )
            )
            locations.append(newlocation)
        }
        return locations
    }

    func fetchData(days: Int, endDate: Date, lat: Double, long: Double, radius: Int) {
        print("fetchData ObservationsViewModel")

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]
        
        let url = "https://waarneming.nl/api/v1/observations/around-point/?days=\(days)&end_date=\(formatCurrentDate(value: endDate))&lat=\(lat)&lng=\(long)&radius=\(radius)"
        
        AF.request(url, headers: headers).responseDecodable(of: Observations.self) { response in
            switch response.result {
            case .success(let observations):
                DispatchQueue.main.async {
                    self.observations = observations
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func formatCurrentDate(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = value
        return dateFormatter.string(from: currentDate)
    }
}
