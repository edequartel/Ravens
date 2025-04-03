//
//  Location.swift
//  Ravens
//
//  Created by Eric de Quartel on 25/03/2024.
//
import Foundation
import SwiftUI
import Alamofire
import MapKit
import SwiftyBeaver

struct ApiResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [LocationJSON] // This is an array of LocationJSON
}

struct LocationJSON: Decodable {
    let id: Int
    let name: String
    let countryCode: String
    let permalink: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryCode = "country_code"
        case permalink
    }
}

struct Location: Identifiable {
  let id = UUID()
  var name: String
  var coordinate: CLLocationCoordinate2D
  var rarity: Int
  var hasPhoto: Bool
  var hasSound: Bool
}

struct Span {
  var latitudeDelta: Double
  var longitudeDelta: Double
  var latitude: Double
  var longitude: Double
}
