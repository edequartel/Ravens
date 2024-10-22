//
//  TimeManager.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/10/2024.
//
import SwiftUI
import Combine
import Alamofire
import SwiftSoup
import UserNotifications

class TimerManager: ObservableObject {
    static let shared = TimerManager()  // Singleton instance

    private var notificationsManager: NotificationsManager!
    private var lastItemCount = 0

    @Published var items: [String] = []

    init() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func setNotificationsManager(_ manager: NotificationsManager) {
        self.notificationsManager = manager
    }

    // Start your task: triggered both in the foreground and via background tasks
    func startYourTask() {
        print("-->> Running background task (foreground or background)")
    }



}

// Fetch data or perform task
//func parseHTMLFromURL() {
//    lastItemCount += 1
//    notificationsManager.scheduleNotificationWithDelay(after: 1, title: "New Notification", body: "Update \(Date())", nr: NSNumber(value: lastItemCount))
//}
//class TimerManager: ObservableObject {
//  private var notificationsManager: NotificationsManager!
//  //    var settings = Settings()
//
//  private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() //*60
//  private var cancellables = Set<AnyCancellable>()
//
//  @Published var items: [String] = [] // Step 1: A list to track items
//  private var lastItemCount = 0
//
//  var Datem: String = ""
//
//  init() {
//    UIApplication.shared.applicationIconBadgeNumber = 0
//    // Listen for timer events and handle task scheduling
//    timer
//      .sink { [weak self] _ in
//        self?.startYourTask()
//      }
//      .store(in: &cancellables)
//  }
//
//  func setNotificationsManager(_ manager: NotificationsManager) { // Step 2: Function to set the NotificationsManager
//    self.notificationsManager = manager
//  }
//
//
//  func startYourTask() {
//    print("-->> new timer polling fromURL")
//    parseHTMLFromURL()
//  }
//
//  deinit {
//    cancellables.removeAll()
//  }
//
//  //this one on timer...
//  func parseHTMLFromURL(completion: (() -> Void)? = nil) {
//    lastItemCount += 1
//    notificationsManager.scheduleNotificationWithDelay(after: 1, title: "speciesName", body: "date time", nr: lastItemCount as NSNumber)
//  }
//}

////this one on timer...
//func parseHTMLFromURL(completion: (() -> Void)? = nil) {
//  print("(settings.parseHTMLFromURL)")
//  //      print("groupID \(settings.selectedSpeciesGroupId)")
//
//  let urlString = "https://waarneming.nl/recent-species/?species_group=1"
//  //      let urlString = "https://waarneming.nl/recent-species/?species_group=\(settings.selectedSpeciesGroupId)"
//  print("parsing... urlString: \(urlString)")
//
//  // Continue with your URL session or network request setup here
//  let headers: HTTPHeaders = [
//    "Accept-Language": "nl" //settings.selectedLanguage
//  ]
//
//  AF.request(urlString, headers: headers).responseString { response in
//    switch response.result {
//    case .success(let html):
//      do {
//        try self.parseHTML(html: html)
//        completion?()
//      } catch {
//        print("Error parsing HTML: \(error.localizedDescription)")
//      }
//
//    case .failure(let error):
//      print("'Error fetching HTML from URL: \(error.localizedDescription)")
//
//    }
//  }
//}
//
//private func parseHTML(html: String) throws {
//  let parseDoc = "<html><body><table>" + html + "</table></body></html>"
//  let doc: Document = try SwiftSoup.parseBodyFragment(parseDoc)
//  let rows = try doc.select("tbody tr")
//
//  // Date formatter to parse the date and time strings
//  let dateFormatter = DateFormatter()
//  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//
//  for row in rows {
//    let speciesScientificNameElement = try row.select(".rarity-species .species-scientific-name")
//    let speciesScientificName = try speciesScientificNameElement.text()
//
//    let speciesNameElement = try row.select(".rarity-species .species-common-name")
//    let speciesName = try speciesNameElement.text()
//
//    let dateElement = try row.select(".rarity-date")
//    let date = try dateElement.text()
//    if !date.isEmpty {
//      Datem = date
//    }
//    let timeElement = try row.select(".rarity-time")
//    var time = try timeElement.text()
//    if time.isEmpty {
//      time = "00:00"
//    }
//
//    let dateTimeString = "\(Datem) \(time)"
//
//    print("update \(dateTimeString)")
//
//    let numObservationsElement = try row.select(".rarity-num-observations .badge-primary")
//    let numObservations = try numObservationsElement.text()
////      let numObservationsInt = Int(numObservations) ?? 0
//
//    if let parsedDate = dateFormatter.date(from: dateTimeString) {
//        // Get current time and subtract 15 minutes
//        let currentTime = Date()
//        let timeMinus15Minutes = Calendar.current.date(byAdding: .minute, value: -15, to: currentTime)
//
//        // Compare parsed date with current time minus 15 minutes
////          if let timeMinus15Minutes = timeMinus15Minutes, parsedDate > timeMinus15Minutes {
////            print("new item as a \(speciesName)")
////        UIApplication.shared.applicationIconBadgeNumber += 1
//      lastItemCount += 1
//          notificationsManager.scheduleNotificationWithDelay(after: 1, title: "\(speciesName)", body: "\(time) \(Datem)", nr: lastItemCount as NSNumber)
////          }
////        else {
////            print("old item as a \(speciesName)")
////          }
//    } else {
//        print("Error: Couldn't parse date and time.")
//    }
//  }
//}
//
