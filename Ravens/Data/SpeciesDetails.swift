//
//  SpeciesDetails.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

struct SpeciesDetails: Codable {
    let id: Int
    let scientific_name: String
    let name: String
    let group: Int
    let group_name: String
    let status: String
    let rarity: String
    let photo: String
    let info_text: String
    let permalink: String
}
