//
//  ObservationsLocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//


import Foundation
import SwiftUI
import Alamofire
import MapKit
import SwiftyBeaver

class ObservationsLocationViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  
  @Published var observations: Observations?
  
  private var keyChainViewModel =  KeychainViewModel()
  
  var locations = [Location]()
  var span: Span = Span(latitudeDelta: 0.1, longitudeDelta: 0.1, latitude: 0, longitude: 0)
  var count: Int = 0
  
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
  
  func getTimeData() {
    let max = (observations?.results.count ?? 0)
    for i in 0..<max {
      if let date = observations?.results[i].date,
         let time = observations?.results[i].time {
        
        // Concatenate date and time strings
        let timeDateStr = date + " " + time
        
        // Date formatter to parse the concatenated date and time string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Convert the concatenated string back to a Date
        if let formattedDate = dateFormatter.date(from: timeDateStr) {
          observations?.results[i].timeDate = formattedDate
        } else {
          // Handle error if the date string could not be parsed
          print("Error: Could not parse date string \(timeDateStr)")
        }
      } else {
        // Handle the case where either the date or time is nil
        print("Error: Missing date or time for index \(i)")
      }
    }
  }
  
  func fetchData(settings: Settings, locationId: Int, limit: Int, offset: Int, completion: (() -> Void)? = nil) {
    log.info("fetchData ObservationsLocationViewModel locationid: \(locationId) limit:\(limit) offset: \(offset)")
    
    keyChainViewModel.retrieveCredentials()
    
    // Add the custom header
    let headers: HTTPHeaders = [
      "authorization": "Token "+keyChainViewModel.token,
      "accept-Language": settings.selectedLanguage,
    ]
    
    let date_after = formatCurrentDate(value: Calendar.current.date(byAdding: .day, value: -14, to: settings.selectedDate)!)
    let date_before = formatCurrentDate(value: settings.selectedDate)
    
    log.info("date after \(date_after)")
    log.info("date before \(date_before)")
    
    var url = endPoint(value: settings.selectedInBetween) + "locations/\(locationId)/observations/"+"?species_group=\(settings.selectedSpeciesGroupId)"
    
    
    if !settings.infinity {
      url = url + "&date_after=\(date_after)&date_before=\(date_before)"
    }
    
    log.info("ObservationsLocationViewModel \(url)")
    
    AF.request(url, headers: headers).responseData { response in
      
      switch response.result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          let observationsSpecies = try decoder.decode(Observations.self, from: data)
          
          DispatchQueue.main.async {
            self.observations = Observations(results: observationsSpecies.results)
            self.count = observationsSpecies.count ?? 0
            self.getTimeData()
            self.getLocations()
            self.getSpan()
            completion?()
          }
        } catch {
          self.log.error("Error ObservationsLocationViewModel decoding JSON: \(error)")
          self.log.error("\(url)")
        }
      case .failure(let error):
        self.log.error("Error ObservationsLocationViewModel: \(error)")
      }
    }
  }
  
  
  
  func getSpan() {
    var latitudes: [Double] = []
    var longitudes: [Double] = []
    
    let max = (observations?.results.count ?? 0)
    for i in 0 ..< max {
      let longitude = observations?.results[i].point.coordinates[0] ?? 52.024052
      let latitude = observations?.results[i].point.coordinates[1] ?? 5.245350
      latitudes.append(latitude)
      longitudes.append(longitude)
    }
    
    let minLatitude = latitudes.min() ?? 0
    let maxLatitude = latitudes.max() ?? 0
    let minLongitude = longitudes.min() ?? 0
    let maxLongitude = longitudes.max() ?? 0
    
    let centreLatitude = (minLatitude + maxLatitude) / 2
    let centreLongitude = (minLongitude + maxLongitude) / 2
    
    let latitudeDelta = (maxLatitude - minLatitude) * 3// 1.5
    let longitudeDelta = (maxLongitude - minLongitude) * 3// 1.5
    
    span = Span(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta, latitude: centreLatitude, longitude: centreLongitude)
  }
  
  func getCameraPosition() -> MapCameraPosition {
    getSpan()
    let center = CLLocationCoordinate2D(
      latitude: span.latitude,
      longitude: span.longitude)
    
    let span = MKCoordinateSpan(
      latitudeDelta: span.latitudeDelta,
      longitudeDelta: span.longitudeDelta)
    
    
    let region = MKCoordinateRegion(center: center, span: span)
    return MapCameraPosition.region(region)
  }
  
}
