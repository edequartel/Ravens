import SwiftUI
import Alamofire
import SwiftyJSON

class WeatherViewModel: ObservableObject {
    @Published var temperature: String = "Loading..."
    
    init() {
        fetchWeatherData()
//        startBackgroundFetch()
    }

    func fetchWeatherData() {
        let apiKey = "50489a3aba189f1c39be52d8a5822acf"
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=Amsterdam&appid=\(apiKey)"

        AF.request(apiUrl).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("\(value)")
//                let json = JSON(value)
//                if let temp = json["main"]["temp"].double {
//                    self.temperature = String(format: "%.1f°C", temp - 273.15)
//                } else {
//                    self.temperature = "N/A"
//                }
            case .failure(let error):
                print("Error fetching weather data: \(error)")
                self.temperature = "N/A"
            }
        }
    }

    func startBackgroundFetch() {
        let apiKey = "50489a3aba189f1c39be52d8a5822acf"
        let apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=Amsterdam&appid=\(apiKey)"

        let backgroundQueue = DispatchQueue(label: "BackgroundFetchQueue", qos: .background, attributes: .concurrent)
        let backgroundFetchTask = URLSession.shared.dataTask(with: URL(string: apiUrl)!) { (_, _, error) in
            if let error = error {
                print("Background fetch error: \(error)")
            } else {
                print("Background fetch successful")
            }
        }

        // Schedule background fetch every 15 minutes
//        backgroundFetchTask.resume()
//        UIApplication.shared.setMinimumBackgroundFetchInterval(15 * 60)
    }
}

struct WeatherView: View {
    @ObservedObject var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            Text("Temperature in Amsterdam:")
                .font(.title)
                .padding()

            Text(viewModel.temperature)
                .font(.headline)
                .padding()
        }
        .onAppear {
            // Fetch weather data when the view appears
            viewModel.fetchWeatherData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh data when the app comes to the foreground
            viewModel.fetchWeatherData()
        }
    }
}

#Preview {
    WeatherView()
}


//@main
//struct WeatherApp: App {
//    var body: some Scene {
//        WindowGroup {
//            WeatherView()
//        }
//    }
//}
