import SwiftUI



// Define the TimePeriod enum
enum TimePeriod: Int, CaseIterable, Identifiable {
  case twoDays = 2
  case week = 7
  case twoWeeks = 14
  case fourWeeks = 28
  case halfYear = 182
  case year = 365
  case infinite = 1024

  var tagValue: String {
    switch self {
    case .twoDays: return "2d"
    case .week: return "1w"
    case .twoWeeks: return "2w"
    case .fourWeeks: return "4w"
    case .halfYear: return "6m"
    case .year: return "1y"
    case .infinite: return "∞"
    }
  }

  // Computed property for description
  var description: String {
    switch self {
    case .twoDays: return "twodays"
    case .week: return "sevendays"
    case .twoWeeks: return "fourteendays"
    case .fourWeeks: return "fourweeks"
    case .halfYear: return "halfayear"
    case .year: return "oneyear"
    case .infinite: return "infinite"
    }
  }

  // Conform to Identifiable for use in ForEach
  var id: Int { self.rawValue }

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.description)
  }
}


// Define the TimePeriod enum
enum TimePeriodRadius: Int, CaseIterable, Identifiable {
  case twoDays = 2
  case week = 7
  case twoWeeks = 14
//  case fourWeeks = 28
//  case halfYear = 182
//  case year = 365
//  case infinite = 1024

  // Computed property for description
  var description: String {
    switch self {
    case .twoDays: return "twodays"
    case .week: return "sevendays"
    case .twoWeeks: return "fourteendays"
//    case .fourWeeks: return "fourweeks"
//    case .halfYear: return "halfayear"
//    case .year: return "oneyear"
//    case .infinite: return "infinite"
    }
  }

  // Conform to Identifiable for use in ForEach
  var id: Int { self.rawValue }

  var localized: LocalizedStringKey {
    LocalizedStringKey(self.description)
  }
}


import SwiftUI

//struct PeriodViewXXX: View {
//    // Binding to a timePeriod variable passed in from a parent view
//    @Binding var timePeriod: TimePeriod
//
//    var body: some View {
//        HStack {
//            Picker(timePeriodlabel, selection: $timePeriod) {
//                ForEach(TimePeriod.allCases, id: \.self) { period in
////                    Text(period.description).tag(period)
//                    Text(period.localized).tag(period)
//                }
//            }
//            .pickerStyle(.menu)
//        }
//    }
//}


// Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        PeriodView()
//    }
//}
