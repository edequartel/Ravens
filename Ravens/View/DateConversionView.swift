//
//  DateConversionView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/09/2024.
//

//import Foundation
import SwiftUI

struct DateConversionView: View {
    let dateString: String
    let timeString: String

    var formattedDate: String {
        if let date = convertStringToDate(dateString) {
          return formatDateWithDayOfWeek(date, timeString)
        } else {
            return "Invalid date"
        }
    }

  var body: some View {
    Text("\(formattedDate)")
      .footnoteGrayStyle()
  }
}

struct DateConversionView_Previews: PreviewProvider {
    static var previews: some View {
        DateConversionView(
          dateString: "2024-12-23", 
          timeString: "12:34")
    }
}

// Function to convert a string to a Date object
func convertStringToDate(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: dateString)
}

// Function to format the Date with day of the week
// Function to format the Date with day of the week
func formatDateWithDayOfWeek(_ date: Date, _ timeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE d MMM yyyy" // "EEEE" for full day of the week
    return dateFormatter.string(from: date)+" "+timeString
}
