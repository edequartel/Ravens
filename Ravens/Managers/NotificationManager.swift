//import SwiftUI
//import UserNotifications
//
//// Notifications Manager class to handle notifications
//class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
//
//    override init() {
//        super.init()
//        // Set the delegate to handle notifications in the foreground
//        UNUserNotificationCenter.current().delegate = self
//    }
//
//    // Request notification permission from the user
//    func requestNotificationPermission() {
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Error requesting permission: \(error.localizedDescription)")
//            } else {
//                print("Permission granted: \(granted)")
//            }
//        }
//    }
//
//    // Function to schedule a notification with a custom delay
//  func scheduleNotificationWithDelay(after seconds: TimeInterval, title: String, body: String, nr: NSNumber) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = UNNotificationSound.default
//        content.badge = nr
//
//        // Set the trigger to fire after a custom time interval
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled \(title) to fire in \(Int(seconds)) seconds.")
//            }
//        }
//    }
//
//    // This function ensures that notifications are shown as banners when the app is in the foreground
//    func userNotificationCenter(
//      _ center: UNUserNotificationCenter,
//      willPresent notification: UNNotification,
//      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound, .badge]) // Display as a banner with sound and badge
//    }
//}
//
//// SwiftUI view to test trigger notifications
////struct StartNotificationView: View {
////    @EnvironmentObject var notificationsManager: NotificationsManager
////    var body: some View {
////      VStack {
////          Button(action: {
////              // Call the function to schedule a notification with a 5-second delay
////              notificationsManager.scheduleNotificationWithDelay(
////                  after: 5,
////                  title: "Wilde eend",
////                  body: "Houten Rietplas"
////              )
////          }) {
////              Text("Notify in 5 Seconds")
////                  .font(.caption)
////                  .padding()
////                  .background(Color.blue)
////                  .foregroundColor(.white)
////                  .cornerRadius(8)
////          }
////      }
////        .onAppear {
////            // Request notification permissions when the view appears
////            notificationsManager.requestNotificationPermission()
////        }
////        .padding()
////    }
////}
