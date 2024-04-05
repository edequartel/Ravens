//
//  Bird.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//
// Data Model

struct Species: Codable, Identifiable {
    var id: Int { species }
    let species: Int
    let name: String
    let scientific_name: String
    let rarity: Int
    let native: Bool
}


