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
  @StateObject var observationsSpeciesViewModel = ObservationsSpeciesViewModel()
  @StateObject var userViewModel =  UserViewModel()
  @StateObject var observationsViewModel = ObservationsViewModel()
  @StateObject var speciesDetailsViewModel = SpeciesDetailsViewModel()
  @StateObject var observationsRadiusViewModel = ObservationsRadiusViewModel()
  @StateObject var observationsLocationViewModel = ObservationsLocationViewModel()
  @StateObject var locationIdViewModel = LocationIdViewModel()
  @StateObject var poiViewModel = POIViewModel()
  @StateObject var geoJSONViewModel = GeoJSONViewModel()
  @StateObject var bookMarksViewModel = BookMarksViewModel()
  @StateObject var observersViewModel = ObserversViewModel()
  @StateObject var areasViewModel = AreasViewModel()
  @StateObject var locationViewModel = SearchLocationViewModel()
  @StateObject var keychainViewModel = KeychainViewModel()


//  @StateObject var notificationsManager = NotificationsManager()
//  @StateObject var timerManager = TimerManager()

  @StateObject var player = Player()
  @StateObject var observationsYearViewModel = ObservationsYearViewModel()

  @State private var showingAlert = false
  @State private var parts: [String] = []
  @State private var badgeCount: Int = 0

  init() {

  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(keychainViewModel)
        .environmentObject(locationManager) //<<location
        .environmentObject(settings)
        .environmentObject(languagesViewModel)
        .environmentObject(speciesViewModel)
        .environmentObject(speciesGroupViewModel)
        .environmentObject(regionsViewModel)
        .environmentObject(regionListViewModel)
        .environmentObject(observationsSpeciesViewModel)
        .environmentObject(userViewModel)

        .environmentObject(observationsViewModel)
        .environmentObject(observationsRadiusViewModel)
        .environmentObject(observationsLocationViewModel)
        .environmentObject(locationIdViewModel)
        .environmentObject(geoJSONViewModel)
        .environmentObject(poiViewModel)
        .environmentObject(speciesDetailsViewModel)

        .environmentObject(bookMarksViewModel)
        .environmentObject(observersViewModel)
        .environmentObject(areasViewModel)

        .environmentObject(player)
        .environmentObject(observationsYearViewModel)

        .environmentObject(locationViewModel)

//        .environmentObject(timerManager) //make it globally available
//        .environmentObject(notificationsManager)

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
        .onAppear {
//          notificationsManager.requestNotificationPermission()
//          timerManager.setNotificationsManager(notificationsManager)
//          print("\(String(describing: locationManager.getCurrentLocation()))")
        }
    }
  }

}
