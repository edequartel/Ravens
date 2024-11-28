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
func formatDateWithDayOfWeek(_ date: Date, _ timeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE d MMM yyyy" // "EEEE" for full day of the week
    return dateFormatter.string(from: date)+" "+timeString
}

func convertStringToFormattedDate(dateString: String, timeString: String) -> String? {
    // Combine date and time into a single string
    let combinedString = "\(dateString) \(timeString)"

    // Create a DateFormatter to parse the input
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Match the input format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure reliable parsing

    guard let date = dateFormatter.date(from: combinedString) else {
        return nil // Return nil if the date parsing fails
    }

    // Create another DateFormatter for the output format
    let outputFormatter = DateFormatter()
    outputFormatter.locale = Locale(identifier: "nl_NL") // Dutch locale
    outputFormatter.dateFormat = "EEEE d MMMM yyyy, HH:mm" // Desired format

    // Format the date to the desired output string
    return outputFormatter.string(from: date)
}
