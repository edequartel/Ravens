import SwiftUI
import Alamofire
import BackgroundTasks
import SwiftySound
import AVFoundation

struct WeatherView: View {
    let audio = ["https://waarneming.nl/media/sound/235344.mp3",
                 "https://waarneming.nl/media/sound/235393.mp3",
                 "https://waarneming.nl/media/sound/235389.mp3",
                 "https://waarneming.nl/media/sound/235338.mp3",
                 "https://waarneming.nl/media/sound/235373.mp3/"
    ]
    var body: some View {
        VStack {
            StreamingQueuPlayerView(audio: audio)
        }
    }
}

#Preview {
    WeatherView()
}


    //class WeatherViewModel: ObservableObject {
    //    @Published var temperature: String = "Loading..."
    //
    //    init() {
    //        fetchWeatherData()
    //        startBackgroundFetch()
    //    }
    //
    //    func fetchWeatherData() {
    //        let apiKey = "50489a3aba189f1c39be52d8a5822acf"
    //        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=London&appid=\(apiKey)"
    //
    //        AF.request(apiUrl).responseJSON { response in
    //            switch response.result {
    //            case .success(let value):
    //                print("Weather data fetched successfully:")
    //                print(value)
    //
    //                let json = JSON(value)
    //                if let temp = json["main"]["temp"].double {
    //                    self.temperature = String(format: "%.1f°C", temp - 273.15)
    //                    print("Temperature: \(self.temperature)")
    //                } else {
    //                    self.temperature = "N/A"
    //                    print("Temperature not available")
    //                }
    //            case .failure(let error):
    //                print("Error fetching weather data: \(error)")
    //                self.temperature = "N/A"
    //            }
    //        }
    //    }
    //
    //
    //
    //    func startBackgroundFetch() {
    //        let backgroundQueue = DispatchQueue(label: "BackgroundFetchQueue", qos: .background, attributes: .concurrent)
    //        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.weatherapp.backgroundfetch", using: backgroundQueue) { task in
    //            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
    //        }
    //
    //        // Schedule background fetch every 15 minutes
    //        do {
    //            let request = BGAppRefreshTaskRequest(identifier: "com.example.weatherapp.backgroundfetch")
    //            request.earliestBeginDate = Date(timeIntervalSinceNow: 15)// * 60)
    //            try BGTaskScheduler.shared.submit(request)
    //        } catch {
    //            print("Error scheduling background fetch task: \(error)")
    //        }
    //    }
    //
    //    func handleAppRefreshTask(task: BGAppRefreshTask) {
    //        // Perform background fetch here
    //        fetchWeatherData()
    //
    //        // Mark the task as completed
    //        task.setTaskCompleted(success: true)
    //    }
    //}
