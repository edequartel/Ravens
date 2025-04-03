//
//  CalenderView.swift
//  Ravens
//
//  Created by Eric de Quartel on 02/04/2025.
//
import SwiftUI
import MijickCalendarView

struct CalenderView: View {
    @State private var selectedDate: Date? = nil
    @State private var selectedRange: MDateRange? = .init()

    var body: some View {
      VStack {
        Text("Selected Date: \(selectedDate?.description ?? "None")")
//        Text("Selected Range: \(selectedRange?.description ?? "None")")
        MCalendarView(selectedDate: $selectedDate, selectedRange: $selectedRange)
      }
    }
}
