////
////  TestDateCompare.swift
////  Ravens
////
////  Created by Eric de Quartel on 15/10/2024.
////
//
import Foundation
import SwiftUI

struct DateComparisonView: View {
    @State private var date1 = ""
    @State private var time1 = ""
    @State private var date2 = ""
    @State private var time2 = ""

    @State private var comparisonResult = ""

    var body: some View {
        VStack(spacing: 20) {
            // Input for first date and time
            VStack {
                Text("First Date and Time")
                TextField("Enter Date (yyyy-MM-dd)", text: $date1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)

                TextField("Enter Time (HH:mm)", text: $time1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)
            }

            // Input for second date and time
            VStack {
                Text("Second Date and Time")
                TextField("Enter Date (yyyy-MM-dd)", text: $date2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)

                TextField("Enter Time (HH:mm)", text: $time2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)
            }

            // Button to trigger comparison
            Button(action: compareDates) {
                Text("Compare")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Display the comparison result
            Text(comparisonResult)
                .padding()
        }
        .padding()
    }

    // Function to compare the input date and time strings
    func compareDates() {
        // Convert string inputs into Date objects
        guard let combinedDateTime1 = convertToDate(dateString: date1, timeString: time1),
              let combinedDateTime2 = convertToDate(dateString: date2, timeString: time2) else {
            comparisonResult = "Invalid date or time format."
            return
        }

        // Compare the two dates
        if combinedDateTime1 < combinedDateTime2 {
            comparisonResult = "First date and time is earlier."
        } else if combinedDateTime1 > combinedDateTime2 {
            comparisonResult = "Second date and time is earlier."
        } else {
            comparisonResult = "Both dates and times are the same."
        }
    }

    // Helper function to convert string date and time into a Date object
    func convertToDate(dateString: String, timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current

        // Check if timeString is empty
        if timeString.isEmpty {
            // Use only the date format if time is missing
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: dateString)
        } else {
            // Use date and time format if both are provided
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let combinedString = "\(dateString) \(timeString)"
            return formatter.date(from: combinedString)
        }
    }
}

struct DateComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        DateComparisonView()
    }
}

//
//struct DateComparisonView: View {
//    @State private var date1 = Date()
//    @State private var time1 = Date()
//    @State private var date2 = Date()
//    @State private var time2 = Date()
//
//    @State private var comparisonResult = ""
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Input for first date and time
//            VStack {
//                Text("First Date and Time")
//                DatePicker("Select Date", selection: $date1, displayedComponents: .date)
//                DatePicker("Select Time", selection: $time1, displayedComponents: .hourAndMinute)
//            }
//
//            // Input for second date and time
//            VStack {
//                Text("Second Date and Time")
//                DatePicker("Select Date", selection: $date2, displayedComponents: .date)
//                DatePicker("Select Time", selection: $time2, displayedComponents: .hourAndMinute)
//            }
//
//            // Button to trigger comparison
//            Button(action: compareDates) {
//                Text("Compare")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//
//            // Display the comparison result
//            Text(comparisonResult)
//                .padding()
//        }
//        .padding()
//    }
//
//    // Function to combine date and time and compare
//    func compareDates() {
//        // Combine date and time for both selections
//        let combinedDateTime1 = combineDateAndTime(date: date1, time: time1)
//        let combinedDateTime2 = combineDateAndTime(date: date2, time: time2)
//
//        // Compare the two dates
//        if combinedDateTime1 < combinedDateTime2 {
//            comparisonResult = "First date and time is earlier."
//        } else if combinedDateTime1 > combinedDateTime2 {
//            comparisonResult = "Second date and time is earlier."
//        } else {
//            comparisonResult = "Both dates and times are the same."
//        }
//    }
//
//    // Helper function to combine a date and time into a single Date object
//    func combineDateAndTime(date: Date, time: Date) -> Date {
//        let calendar = Calendar.current
//        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
//        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
//
//        var combinedComponents = DateComponents()
//        combinedComponents.year = dateComponents.year
//        combinedComponents.month = dateComponents.month
//        combinedComponents.day = dateComponents.day
//        combinedComponents.hour = timeComponents.hour
//        combinedComponents.minute = timeComponents.minute
//
//        return calendar.date(from: combinedComponents) ?? Date()
//    }
//}
//
//struct DateComparisonView_Previews: PreviewProvider {
//    static var previews: some View {
//        DateComparisonView()
//    }
//}
