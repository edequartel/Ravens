//
//  Observation.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import Foundation

// MARK: - Observation
struct Observations: Codable {
    var count: Int?
    var next, previous: URL?
    var results: [Observation]
}

struct Observation: Codable, Identifiable {
    var id: Int = 0
    var permalink: String = ""
    var date: String = ""
    var time: String? = "11:00"
    var species_detail: SpeciesDetail
    var number: Int = 0
    var sex: String = ""
    var activity: Int = 0
    var life_stage: Int = 0
    var method: Int = 0
    var has_photo: Bool = true
    var has_sound: Bool = true
    var point: Point
    var location_detail: LocationDetail
    var rarity: Int = 0
    var is_certain: Bool = true
    var is_escape: Bool = true
    var validation_status: String = ""
    var user: Int = 0
    
}

struct SpeciesDetail: Codable {
    var id: Int = 0
    var scientific_name: String = ""
    var name: String = ""
    var group: Int = 0
}

struct Point: Codable {
    var type: String = ""
    var coordinates: [Double] = [0]
}

struct LocationDetail: Codable {
    var id: Int = 0
    var name: String = ""
    var country_code: String = ""
    var permalink: String = ""
}
