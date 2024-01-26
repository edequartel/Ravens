//
//  RavensApp.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//

import SwiftUI

import SwiftyBeaver

class AppDelegate: NSObject, UIApplicationDelegate {
    let log = SwiftyBeaver.self
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let file = FileDestination()
//        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"  // full datetime, colored log level and message
        file.minLevel = .verbose
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
    
    @StateObject private var settings = Settings()
    let observationsSpeciesViewModel = ObservationsSpeciesViewModel()
    let observationsModel =
    ObservationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(observationsSpeciesViewModel)
                .environmentObject(observationsModel)
        }
    }
}
