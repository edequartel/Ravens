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
        return .gray
    case 1:
        return .green //common
    case 2:
        return .blue //uncommon
    case 3:
        return .orange //rare
    case 4:
        return .red //very rare
    default:
        return .clear //You can provide a default color or handle other cases as needed
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
}
