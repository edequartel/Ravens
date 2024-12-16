import SwiftUI

// Define the TimePeriod enum
enum TimePeriod: Int, CaseIterable, Identifiable {
    case twoDays = 2
    case week = 7
    case twoWeeks = 14
    case fourWeeks = 28
    case halfYear = 182
    case year = 365
    case infinite = 100

    // Computed property for description
    var description: String {
        switch self {
        case .twoDays: return "2 Days"
        case .week: return "1 Week"
        case .twoWeeks: return "2 Weeks"
        case .fourWeeks: return "4 Weeks"
        case .halfYear: return "Half a Year"
        case .year: return "1 Year"
        case .infinite: return "Infinite"
        }
    }

    // Conform to Identifiable for use in ForEach
    var id: Int { self.rawValue }
}

struct PeriodView: View {
    // State variable with UserDefaults persistence
    @AppStorage("selectedTimePeriod") private var selectedTimePeriodRawValue: Int = TimePeriod.week.rawValue

    // State property to track selectedTimePeriod
    @State private var selectedTimePeriod: TimePeriod = .week

    var body: some View {
        HStack {
            Text("Select a Time Period")
                .font(.headline)
                .padding()

          Spacer()

            Picker("Time Period", selection: $selectedTimePeriod) {
                ForEach(TimePeriod.allCases) { period in
                    Text(period.description).tag(period)
                }
            }
            .pickerStyle(.menu) // You can change this to .menu or .segmented if preferred
            .padding()
            .onChange(of: selectedTimePeriod) {
                            selectedTimePeriodRawValue = selectedTimePeriod.rawValue
                        }

//            Text("You selected: \(selectedTimePeriod.description) (\(selectedTimePeriod.rawValue) days)")
//                .padding()
        }
        .onAppear {
            selectedTimePeriod = TimePeriod(rawValue: selectedTimePeriodRawValue) ?? .week
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PeriodView()
    }
}
