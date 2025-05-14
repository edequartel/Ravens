//
//  SwiftDataExample.swift
//  Ravens
//
//  Created by Eric de Quartel on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class Task {
    var title: String
    var isCompleted: Bool
//
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
