//
//  YearView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/03/2024.
//

import SwiftUI
import SwiftUI
import Charts

struct YearView: View {
    // An array representing monthly views, you can uncomment and use this hardcoded data or pass it externally.
    //    var monthlyViews: [Double] = [120, 150, 80, 200, 100, 180, 250, 300, 160, 120, 200, 180]
    var monthlyViews: [Double]

    var body: some View {
        // The main body of the YearView, containing a Chart with BarMarks.
        Chart {
            // Using ForEach to iterate through the monthlyViews array.
            ForEach(0..<monthlyViews.count, id: \.self) { index in
                let monthName = getMonthName(for: index)
                // Creating a BarMark for each month with its corresponding value.
                BarMark(
                    x: .value("Month", monthName), // Labeling x-axis with "Month" and index as the value.
                    y: .value("Value", monthlyViews[index]) // Labeling y-axis with "Value" and monthlyViews value.
                )
            }
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


struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(monthlyViews: [120, 150, 80, 200, 100, 180, 250, 300, 160, 120, 200, 180])
    }
}
