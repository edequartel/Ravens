import SwiftUI
import Alamofire
import BackgroundTasks
//import AVFoundation

import Foundation

//data

struct WeatherResponse: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let type: Int
    let id: Int
    let country: String
    let sunrise: Int
    let sunset: Int
}


//viewmodel

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?

    func fetchWeather() {
        AF.request("https://api.openweathermap.org/data/2.5/weather?q=Werkhoven&appid=50489a3aba189f1c39be52d8a5822acf")
            .validate()
            .responseDecodable(of: WeatherResponse.self) { response in
                switch response.result {
                case .success(let weather):
                    self.weather = weather
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
    }
}

//view
import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            if let weather = viewModel.weather {
                Text("Plaats: \(weather.name)")
                Text("Voelt als: \(kelvinToCelsius(kelvin: weather.main.feels_like))")
                let Tc = kelvinToCelsius(kelvin: weather.main.temp)
                Text("Temperatuur: \(Tc)")
//                Text("\(weather.weather.description.description)")
                // Add more Text views or UI elements as needed
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            viewModel.fetchWeather()
        }
    }
    
    func kelvinToCelsius(kelvin: Double) -> String {
        return String(format: "%.1f°C", kelvin - 273.15)
    }
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
////                let json = JSON(value)
////                if let temp = json["main"]["temp"].double {
////                    self.temperature = String(format: "%.1f°C", temp - 273.15)
////                    print("Temperature: \(self.temperature)")
////                } else {
////                    self.temperature = "N/A"
////                    print("Temperature not available")
////                }
//                
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
//
//
