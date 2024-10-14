//
//  HTMLDocument.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/06/2024.
//

import Foundation
import SwiftUI

struct HTMLDocument: Identifiable {
    let id: UUID = UUID()
    let date: String
    let time: String
    
    let linkRarity: String
    let rarity: Int
    
    let speciesCommonName: String
    let speciesScientificName: String
    
    let location: String
    let locationId: Int
    
    let numObservations: Int
    let description: String?
    
    let linkSpeciesObservations: String
    let linkLocations: String

    let observationNr: Int
  
}

