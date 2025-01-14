//
//  RavensApp.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver
import SwiftData
import BackgroundTasks
import UserNotifications

class URLHandler: ObservableObject {
    @Published var urlString: String = ""
}

class AppDelegate: NSObject, UIApplicationDelegate {
  let log = SwiftyBeaver.self

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    configureLogging()

    return true
  }

  // Function to configure SwiftyBeaver logging
  func configureLogging() {
    // File logging destination
    let file = FileDestination()
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
    file.minLevel = .warning
    file.levelString.error = "Ravens"
    file.logFileURL = URL(fileURLWithPath: "/Users/ericdequartel/Developer/_myApps/Ravens/ravens.log")
    // Console logging destination
    let console = ConsoleDestination()
    console.levelString.error = "Ravens"
    console.format = ">> $DHH:mm:ss.SSS$d $C$L$c: $M"
    console.minLevel = .error
    // Add both destinations to SwiftyBeaver
    // log.addDestination(file)
    log.addDestination(console)
  }
}

@main
struct RavensApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @StateObject var locationManager = LocationManagerModel()
  @StateObject var settings = Settings()
  @StateObject var languagesViewModel = LanguagesViewModel()
  @StateObject var speciesViewModel = SpeciesViewModel()
  @StateObject var speciesGroupViewModel = SpeciesGroupsViewModel()
  @StateObject var regionsViewModel = RegionsViewModel()
  @StateObject var regionListViewModel = RegionListViewModel()
  @StateObject private var observationsLocation = ObservationsViewModel()
  @StateObject private var observationsSpeciesViewModel = ObservationsViewModel()
  @StateObject private var observationsSpecies = ObservationsViewModel()
  @StateObject private var observationsViewModel = ObservationsViewModel()
  @StateObject private var observationsUser = ObservationsViewModel()
  @StateObject var userViewModel =  UserViewModel()
  @StateObject var speciesDetailsViewModel = SpeciesDetailsViewModel()
  @StateObject var poiViewModel = POIViewModel()
  @StateObject var bookMarksViewModel = BookMarksViewModel(fileName: "bookmarks.json")
  @StateObject var observersViewModel = ObserversViewModel() //??
  @StateObject var areasViewModel = AreasViewModel() //??
  @StateObject var geoJSONViewModel = GeoJSONViewModel()

  @StateObject var locationViewModel = SearchLocationViewModel()
  @StateObject var keychainViewModel = KeychainViewModel()
  @StateObject private var accessibilityManager = AccessibilityManager()
  @StateObject var player = Player()

  @State private var showingAlert = false
  @State private var parts: [String] = []
  @State private var badgeCount: Int = 0

  var body: some Scene {
    WindowGroup {
      ContentView(
        observationUser: observationsUser,
        observationsLocation : observationsLocation,
        observationsSpecies: observationsSpecies
      )
        .environmentObject(keychainViewModel)
        .environmentObject(locationManager)
        .environmentObject(settings)
        .environmentObject(languagesViewModel)
        .environmentObject(speciesViewModel)
        .environmentObject(speciesGroupViewModel)
        .environmentObject(regionsViewModel)
        .environmentObject(regionListViewModel)
        .environmentObject(userViewModel)
        .environmentObject(observationsSpeciesViewModel)
        .environmentObject(poiViewModel)
        .environmentObject(speciesDetailsViewModel)
        .environmentObject(bookMarksViewModel)
        .environmentObject(observersViewModel)
        .environmentObject(areasViewModel)
        .environmentObject(player)
        .environmentObject(locationViewModel)
        .environmentObject(accessibilityManager)
        .environmentObject(geoJSONViewModel)

        .onOpenURL { url in
          // Handle the URL appropriately
          let urlString = url.absoluteString.replacingOccurrences(of: "ravens://", with: "")
          self.parts = urlString.split(separator: "/").map(String.init)
          showingAlert = true
        }

        .alert(isPresented: $showingAlert) {
          Alert(title: Text("Add Observer"),
                message: Text("Do you want to append this \(parts[0].replacingOccurrences(of: "_", with: " ")) \(parts[1])?"),
                primaryButton: .default(Text("Yes")) {
            print("Appending \(parts[0]) \(parts[1])")
            observersViewModel.appendRecord(name: self.parts[0], userID:  Int(self.parts[1]) ?? 0)
          },
                secondaryButton: .cancel(Text("No")))
        }
//        .onAppear {
////          notificationsManager.requestNotificationPermission()
////          timerManager.setNotificationsManager(notificationsManager)  
////          print("\(String(describing: locationManager.getCurrentLocation()))")
//        }
    }
  }

}


