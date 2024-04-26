//
//  YearView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/03/2024.
//

import SwiftUI
import SwiftUI
import Charts
import SwiftyBeaver

struct YearView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject var observationsYearViewModel: ObservationsYearViewModel
    var speciesId: Int
    
    var body: some View {
        VStack {
            Text("obs 2023")
            Chart {
                // Using ForEach to iterate through the monthlyViews array.
                ForEach(0..<observationsYearViewModel.months.count, id: \.self) { index in
                    if index < observationsYearViewModel.months.count {
                        // Getting the month name from the index.
//                    print("index: \(index)")
                        let monthName = getMonthName(for: index)
//                        let firstCharacterString = String(monthName.first ?? Character(""))
                        // Creating a BarMark for each month with its corresponding value.
                        BarMark(
                            x: .value("Month", monthName), // Labeling x-axis with "Month" and index as the value.
                            y: .value("Value", observationsYearViewModel.months[index]) // Labeling y-axis with "Value" and monthlyViews value.
                        )
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
        }
        .onAppear() {
            observationsYearViewModel.fetchMonthData(speciesId: self.speciesId)
//            observationsYearViewModel.deleteFilesInFolder() //deze bij legen cache setting zetten !!!
        }
    }
    
    
    // Function to get the month name from index
    func getMonthName(for index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        if let date = Calendar.current.date(bySetting: .month, value: index + 1, of: Date()) {
            return dateFormatter.string(from: date)
        } else {
            return "Unknown"
        }
    }
}

//monthlyViews: [120, 150, 80, 200, 100, 180, 250, 300, 160, 120, 200, 180]
// Preview for the YearView.
struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(speciesId: 65)
    }
}
