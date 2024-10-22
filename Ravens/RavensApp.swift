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
        
        let file = FileDestination()
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
        file.minLevel = .warning
        file.levelString.error = "Ravens"
        file.logFileURL = URL(fileURLWithPath: "/Users/ericdequartel/Developer/_myApps/Ravens/ravens.log")
        
        let console = ConsoleDestination()  // log to Xcode Console
        console.levelString.error = "Ravens"
        console.format = ">> $DHH:mm:ss.SSS$d $C$L$c: $M"
        console.minLevel = .error
        
        log.addDestination(console)
//        log.addDestination(file)

      // Register background task
      BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.app.refresh", using: nil) { task in
          self.handleAppRefresh(task: task as! BGAppRefreshTask)
      }

        return true
    }

  func handleAppRefresh(task: BGAppRefreshTask) {
      // Schedule the next background refresh task
      scheduleAppRefresh()

      // Execute your task (e.g., data fetching or notifications)
      TimerManager.shared.startYourTask()

      // Notify the system that the task is complete
      task.setTaskCompleted(success: true)
  }

  // Schedule background task
  func scheduleAppRefresh() {
      let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
      request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule after 15 minutes

      do {
          try BGTaskScheduler.shared.submit(request)
      } catch {
          print("Failed to schedule background refresh: \(error.localizedDescription)")
      }
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
      // Schedule the background task when the app enters the background
      scheduleAppRefresh()
  }

}

//// Now let’s log!
//log.verbose("not so important")  // prio 1, VERBOSE in silver
//log.debug("something to debug")  // prio 2, DEBUG in green
//log.info("a nice information")   // prio 3, INFO in blue
//log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
//log.error("ouch, an error did occur!")  // prio 5, ERROR in red
//
//// log anything!
//log.verbose(123)
//log.debug(123)
//log.info(-123.45678)
//log.warning(Date())
//log.error(["I", "like", "logs!"])
//log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])

// optionally add context to a log message
//console.format = "$L: $M $X"
//log.debug("age", context: 123)  // "DEBUG: age 123"
//log.info("my data", context: [1, "a", 2]) // "INFO: my data [1, \"a\", 2]"

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

  @StateObject var notificationsManager = NotificationsManager()
  @StateObject var timerManager = TimerManager()

  @StateObject var player = Player()

  @StateObject var observationsYearViewModel = ObservationsYearViewModel()

  let urlHandler = URLHandler()

  //
  let center = UNUserNotificationCenter.current()


  @State private var showingAlert = false
  @State private var parts: [String] = []
  @State private var badgeCount: Int = 0

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(KeychainViewModel())
        .environmentObject(locationManager)
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
        .environmentObject(urlHandler)


        .environmentObject(timerManager) //make it globally available
        .environmentObject(notificationsManager)


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
          notificationsManager.requestNotificationPermission()
          timerManager.setNotificationsManager(notificationsManager)
        }
    }
  }
}
