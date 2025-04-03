//
//  Region.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import Foundation

struct RegionList: Codable, Identifiable {
    var id: Int
    let region: Int
    let speciesGroup: Int

    enum CodingKeys: String, CodingKey {
        case id
        case region
        case speciesGroup = "species_group"
    }
}
