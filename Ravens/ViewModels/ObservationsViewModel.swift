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
    
    
    ///
    func locations()->[Location] {
        var locations = [Location]()
        
        let max = (observations?.count ?? 0 > 99) ? 99 : (observations?.count ?? 0)
//        let max = (observations?.count ?? 0)
        for i in 0 ..< max {
    
            print("==>    \(observations?.count ?? 0) - \(i)")
            
            
            let name = observations?.results[i].species_detail.name ?? "Unknown"
            let latitude = observations?.results[i].point.coordinates[1] ?? 52.024052
            let longitude = observations?.results[i].point.coordinates[0] ?? 5.245350

            let newLocation = Location(name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))

            if newLocation != nil {
                locations.append(newLocation)
            } else {
                print("Error in index or initialization")
            }


           
        }
        return locations
    }
    
    ///
    func fetchData(days: Int, endDate: Date, lat: Double, long: Double, radius: Int) {
        print("fetchData ObservationsViewModel")

        // Add the custom header 'Accept-Language: nl'
        let headers: HTTPHeaders = [
            "Accept-Language": "nl"
        ]
        
        let url = "https://waarneming.nl/api/v1/observations/around-point/?days=\(days)&end_date=\(formatCurrentDate(value: endDate))&lat=\(lat)&lng=\(long)&radius=\(radius)"
        
        print("\(url)")
        
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
