//
//  SpeciesDetails.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

struct SpeciesDetails: Codable {
    let id: Int
    let scientificName: String
    let name: String
    let group: Int
    let groupName: String
    let status: String
    let rarity: String
    let photo: String
    let infoText: String
    let permalink: String

    enum CodingKeys: String, CodingKey {
        case id
        case scientificName = "scientific_name"
        case name
        case group
        case groupName = "group_name"
        case status
        case rarity
        case photo
        case infoText = "info_text"
        case permalink
    }
}
