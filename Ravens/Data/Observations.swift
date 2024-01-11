//
//  Observation.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation
/*import*/ /*OptionallyDecodable*/ // https://github.com/idrougge/OptionallyDecodable

// MARK: - Observation
struct Observations: Codable {
    var count: Int?
    var next, previous: URL?
    var results: [Observation]
}

struct Observation: Codable, Identifiable {
    let id: Int
    let permalink: String
    let date: String
    let time: String?
    let species_detail: SpeciesDetail
    let number: Int
    let sex: String
    let activity: Int
    let life_stage: Int
    let method: Int
    let has_photo: Bool
    let has_sound: Bool
    let point: Point
    let location_detail: LocationDetail
    let rarity: Int
    let is_certain: Bool
    let is_escape: Bool
    let validation_status: String
    let user: Int
}

struct SpeciesDetail: Codable {
    let id: Int
    let scientific_name: String
    let name: String
    let group: Int
}

struct Point: Codable {
    let type: String
    let coordinates: [Double]
}

struct LocationDetail: Codable {
    let id: Int
    let name: String
    let country_code: String
    let permalink: String
}
