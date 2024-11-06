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
    let species_group: Int
}
