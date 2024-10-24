//
//import SwiftUI
//import Alamofire
//
//// Define the structure for the list of recordings with pagination details
//struct RecordingsList: Decodable {
//    var numRecordings: String
//    var numSpecies: String
//    var page: Int
//    var numPages: Int
//    var recordings: [Recording]
//}
//
//// Model
//// Define the structure of the JSON data
//struct Recording: Codable {
//  var also: [String]
//  var alt: Int? // String?
//  var animalSeen: String?
//  var auto: String?
//  var birdSeen: String?
//  var cnt: String
//  var date: String
//  var dvc: String?
//  var en: String
//  var file: URL
//  var fileName: String
//  var gen: String
//  var group: String
//  var id: Int
//  var lat: String
//  var length: String
//  var lic: String // URL
//  var loc: String
//  var lng: String
//  var method: String
//  var mic: String?
//  var osci: Osci
//  var playbackUsed: String?
//  var q: String
//  var rec: String
//  var regnr: String?
//  var rmk: String?
//  var sex: String?
//  var sono: Sono
//  var sp: String
//  var smp: Int? // String?
//  var ssp: String?
//  var stage: String?
//  var temp: String?
//  var time: String
//  var type: String
//  var uploaded: String
//  var url: URL
//  enum CodingKeys: String, CodingKey {
//    case id, gen, sp, ssp, group, en, rec, cnt, loc, lat, lng, alt, type,
//         sex, stage, method, url, file, lic, q, length, time, date, uploaded, also,
//         rmk, temp, regnr, auto, dvc, mic, smp, sono, osci
//    case birdSeen = "bird-seen"
//    case animalSeen = "animal-seen"
//    case playbackUsed = "playback-used"
//    case fileName = "file-name"
//  }
//  //
//  struct Sono: Codable {
//    var small: String?
//    var med: String?
//    var large: String?
//    var full: String?
//  }
//  //
//  struct Osci: Codable {
//    var small: String?
//    var med: String?
//    var large: String?
//  }
//}
//
//class RecordingsListViewModel: ObservableObject {
//  @Published var recordingsList: RecordingsList?
//  @Published var isLoading = false
//  @Published var errorMessage: String?
//
//  func fetchRecordings(from urlString: String) {
//    self.isLoading = true
//    AF.request(urlString).responseJSON { response in
//      DispatchQueue.main.async {
//        self.isLoading = false
//        print("Response: \(response)")
//        switch response.result {
//        case .success(let value):
//          print("JSON Response: \(value)")
//          if let data = response.data {
//            let decoder = JSONDecoder()
//            do {
//              let list = try decoder.decode(RecordingsList.self, from: data)
//              self.recordingsList = list
//            } catch {
//              self.errorMessage = error.localizedDescription
//            }
//          }
//        case .failure(let error):
//          self.errorMessage = error.localizedDescription
//        }
//      }
//    }
//  }
//}
//
//struct XantoView: View {
//    @ObservedObject var viewModel: RecordingsListViewModel
//
//    var body: some View {
//        NavigationView {
//            List {
//                if let recordings = viewModel.recordingsList?.recordings {
//                    ForEach(recordings, id: \.id ) { recording in
//                        VStack(alignment: .leading) {
//                          Text(recording.fileName)
//                                .font(.headline)
//                            Text(recording.cnt)
//                                .font(.subheadline)
//                        }
//                    }
//                } else if viewModel.isLoading {
//                    ProgressView("Loading...")
//                } else {
//                    Text("No data available")
//                }
//            }
//            .navigationTitle("Recordings")
//            .onAppear {
//                viewModel.fetchRecordings(from: "https://xeno-canto.org/api/2/recordings?query=bluethroat")
//            }
//        }
//    }
//}
