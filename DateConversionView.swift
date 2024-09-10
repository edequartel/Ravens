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
            return formatDateWithDayOfWeek(date)
        } else {
            return "Invalid date"
        }
    }

  var body: some View {
    Text("\(formattedDate)")
  }

    // Function to convert a string to a Date object
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }

    // Function to format the Date with day of the week
    func formatDateWithDayOfWeek(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE d MMM yy" // "EEEE" for full day of the week
        return dateFormatter.string(from: date)+" "+timeString
    }
}

struct DateConversionView_Previews: PreviewProvider {
    static var previews: some View {
        DateConversionView(
          dateString: "2024-12-23", 
          timeString: "12:34")
    }
}
