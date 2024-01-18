//
//  ExtensionsAndFunctions.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import Foundation
import SwiftUI

func formatCurrentDate(value: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let currentDate = value
    return dateFormatter.string(from: currentDate)
}

func myColor(value: Int) -> Color {
    switch value {
    case 0:
        return .gray //onbekend
    case 1:
        return .green //algemeen
    case 2:
        return .blue //vrij algemeen
    case 3:
        return .orange //rare
    case 4:
        return .red //very rare
    default:
        return .gray //You can provide a default color or handle other cases as needed
    }
}
