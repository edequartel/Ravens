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
        return .gray //common
    case 1:
        return .green //uncom
    case 2:
        return .blue
    case 3:
        return .orange
    case 4:
        return .red
    default:
        return .clear // You can provide a default color or handle other cases as needed
    }
}
