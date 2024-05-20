//
//  RavensApp.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI
import SwiftyBeaver
import SwiftData

import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let log = SwiftyBeaver.self
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let file = FileDestination()
        //        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
        file.minLevel = .warning
        file.levelString.error = "Ravens"
        file.logFileURL = URL(fileURLWithPath: "/Users/ericdequartel/Developer/_myApps/Ravens/ravens.log")
        
        let console = ConsoleDestination()  // log to Xcode Console
        console.levelString.error = "Ravens"
        console.format = ">> $DHH:mm:ss.SSS$d $C$L$c: $M"
        //        console.format = "EDQ: $Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"
        console.minLevel = .error
        
        log.addDestination(console)
        log.addDestination(file)
        
        return true
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
    //    @StateObject var fetchRequestManager = FetchRequestManager()
    let observersViewModel = ObserversViewModel()
    let urlHandler = URLHandler() // create instance
    
    //
    let center = UNUserNotificationCenter.current()

    
    @State private var showingAlert = false
    @State private var parts: [String] = []
    @State private var badgeCount: Int = 0
    
    init() { //get permissions notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                // Handle the error here.
                print(error.localizedDescription)
            }
            // Enable or disable features based on the authorization.
        }
    }
    //^
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(KeychainViewModel())
                .environmentObject(UserViewModel())
                .environmentObject(Settings())
                .environmentObject(ObservationsSpeciesViewModel(settings: Settings()))
                .environmentObject(ObservationsViewModel())
                .environmentObject(RegionViewModel(settings: Settings()))
                .environmentObject(RegionListViewModel(settings: Settings()))
                .environmentObject(SpeciesGroupViewModel(settings: Settings()))
                .environmentObject(SpeciesDetailsViewModel(settings: Settings()))
                .environmentObject(ObservationsUserViewModel(settings: Settings()))
                .environmentObject(Player())
                .environmentObject(ObservationsLocationViewModel())
                .environmentObject(ObservationsYearViewModel(settings: Settings()))
                .environmentObject(ObserversViewModel())
                .environmentObject(BookMarksViewModel())
                .environmentObject(urlHandler) // use instance
                .environmentObject(observersViewModel) // use instance
                .environmentObject(AreasViewModel()) // use instance
            
            //v
                .onOpenURL { url in
                    // Handle the URL appropriately
                    let urlString = url.absoluteString.replacingOccurrences(of: "ravens://", with: "")
                    self.parts = urlString.split(separator: "/").map(String.init)
                    showingAlert = true

                    
//                    observersViewModel.appendRecord(name: parts[0], userID:  Int(parts[1]) ?? 0)
//                    
                    
                    
                    // Create the notification content
                    let content = UNMutableNotificationContent()
                    content.title = "URL Opened"
                    content.body = "The app opened a URL: \(url)"
                    
                    // Create the trigger
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    // Create the request
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    // Schedule the request with the system.
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.add(request) { (error) in
                        if let error = error {
                            // Handle any errors.
                            print(error.localizedDescription)
                        }
                    }
                    
                    //Update badge number
                    // Then in the function where you want to increase the badge count
                    center.setBadgeCount(0)
//                    center.setBadgeCount(badgeCount + 1) { error in
//                        if let error = error {
//                            print("Error setting badge count: \(error)")
//                        } else {
//                            badgeCount += 1
//                        }
//                    }
                    

                }
            
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Append URL"),
                          message: Text("Do you want to append this \(parts[0].replacingOccurrences(of: "_", with: " ")) \(parts[1])?"),
                          primaryButton: .default(Text("Yes")) {
                        print("Appending \(parts[0]) \(parts[1])")
                        observersViewModel.appendRecord(name: self.parts[0], userID:  Int(self.parts[1]) ?? 0)
                          },
                          secondaryButton: .cancel(Text("No")))
                }
            //^
        }
    }
}

