//
//  TabSpeciesView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import Charts

struct SpeciesView: View {
  @State private var showFirstView = false

  @ObservedObject var observationsSpecies: ObservationsViewModel

  @EnvironmentObject var settings: Settings
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel

  @State var showChart: Bool = false

  var item: Species

  @Binding var selectedSpeciesID: Int?

  var body: some View {
    VStack {
      if showView { Text("SpeciesView").font(.customTiny) }

      if showFirstView && !accessibilityManager.isVoiceOverEnabled {
        MapObservationsSpeciesView(
          observationsSpecies: observationsSpecies,
          item: item)
      } else {
        VStack {
          ObservationsSpeciesView(
            observationsSpecies: observationsSpecies,
            item: item,
            selectedSpeciesID: $selectedSpeciesID,
            timePeriod: $settings.timePeriodSpecies
          )
        }
      }
    }

    .toolbar {
      if !accessibilityManager.isVoiceOverEnabled {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showFirstView.toggle()
          }) {
            Image(systemSymbol: .rectangle2Swap) // Replace with your desired image
              .uniformSize()
          }
          .accessibility(label: Text("Switch view"))
        }
      }
      
      if [1, 2, 3, 14].contains(settings.selectedSpeciesGroup) {
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: BirdListView(scientificName: item.scientificName, nativeName: item.name)) {
            Image(systemName: "waveform")
              .uniformSize()
          }
          .background(Color.clear)
          .accessibility(label: Text(audioListView))
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        BookmarkButtonView(speciesID: item.speciesId)
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(destination: SpeciesDetailsView(speciesID: item.speciesId)) {
          Image(systemName: "arrowshape.turn.up.forward")
                  .uniformSize()
          }
          .background(Color.clear)
          .accessibility(label: Text(infoSpecies))

      }

      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink(destination: PickTimePeriodeSpeciesView(
          timePeriod: $settings.timePeriodSpecies
        )) {
          Image(systemSymbol: .ellipsisCircle)
            .uniformSize()
            .accessibility(label: Text(sortAndFilterSpecies))
        }
      }
    }
    .onAppear {
      settings.initialSpeciesLoad = true
    }
  }
}

struct EbirdNotableObservation: Codable {
  let speciesCode: String?
  let comName: String?
  let sciName: String?
  let locId: String?
  let locName: String?
  let obsDt: String?
  let howMany: Int?
  let lat: Double?
  let lng: Double?
  let subId: String?
  let obsId: String?
  let userDisplayName: String?
  let evidence: String?
  let hasRichMedia: Bool?
  let obsReviewed: Bool?
  let obsValid: Bool?

  enum CodingKeys: String, CodingKey {
    case speciesCode
    case comName
    case sciName
    case locId
    case locName
    case obsDt
    case howMany
    case lat
    case lng
    case subId
    case obsId
    case userDisplayName
    case evidence
    case hasRichMedia
    case obsReviewed
    case obsValid
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    speciesCode = try container.decodeIfPresent(String.self, forKey: .speciesCode)
    comName = try container.decodeIfPresent(String.self, forKey: .comName)
    sciName = try container.decodeIfPresent(String.self, forKey: .sciName)
    locId = try container.decodeIfPresent(String.self, forKey: .locId)
    locName = try container.decodeIfPresent(String.self, forKey: .locName)
    obsDt = try container.decodeIfPresent(String.self, forKey: .obsDt)
    howMany = Self.decodeFlexibleInt(from: container, forKey: .howMany)
    lat = try container.decodeIfPresent(Double.self, forKey: .lat)
    lng = try container.decodeIfPresent(Double.self, forKey: .lng)
    subId = try container.decodeIfPresent(String.self, forKey: .subId)
    obsId = try container.decodeIfPresent(String.self, forKey: .obsId)
    userDisplayName = try container.decodeIfPresent(String.self, forKey: .userDisplayName)
    evidence = try container.decodeIfPresent(String.self, forKey: .evidence)
    hasRichMedia = try container.decodeIfPresent(Bool.self, forKey: .hasRichMedia)
    obsReviewed = try container.decodeIfPresent(Bool.self, forKey: .obsReviewed)
    obsValid = try container.decodeIfPresent(Bool.self, forKey: .obsValid)
  }

  private static func decodeFlexibleInt(
    from container: KeyedDecodingContainer<CodingKeys>,
    forKey key: CodingKeys
  ) -> Int? {
    if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
      return value
    }

    if let value = try? container.decodeIfPresent(String.self, forKey: key) {
      return Int(value)
    }

    return nil
  }
}

class EbirdNotableObservationsViewModel: ObservableObject {
  @Published var observations: [Obs]?
  @Published var count = 0
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let endpoint = "https://api.ebird.org/v2/data/obs/NL/recent/notable?back=7&detail=full"

  func fetchData(settings: Settings) {
    guard let url = URL(string: endpoint) else { return }

    guard let token = Self.apiToken, !token.isEmpty else {
      observations = []
      count = 0
      errorMessage = "Missing eBird API token."
      return
    }

    isLoading = true
    errorMessage = nil

    var request = URLRequest(url: url)
    request.setValue(token, forHTTPHeaderField: "X-eBirdApiToken")
    request.setValue(settings.selectedLanguage.hasPrefix("nl") ? "nl" : "en", forHTTPHeaderField: "Accept-Language")

    URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        self.isLoading = false

        if let error = error {
          self.errorMessage = error.localizedDescription
          return
        }

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
          self.errorMessage = "eBird request failed: \(httpResponse.statusCode)"
          self.observations = []
          self.count = 0
          return
        }

        guard let data = data else {
          self.observations = []
          self.count = 0
          return
        }

        do {
          let ebirdObservations = try JSONDecoder().decode([EbirdNotableObservation].self, from: data)
          let observations = Self.uniqueObservations(from: ebirdObservations)
          self.observations = observations
          self.count = observations.count
        } catch {
          self.errorMessage = error.localizedDescription
          self.observations = []
          self.count = 0
        }
      }
    }.resume()
  }

  private static var apiToken: String? {
    if let token = Bundle.main.object(forInfoDictionaryKey: "EBIRD_API_TOKEN") as? String {
      return normalizedToken(token)
    }
    return normalizedToken(ProcessInfo.processInfo.environment["EBIRD_API_TOKEN"])
  }

  private static func normalizedToken(_ token: String?) -> String? {
    let value = token?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if value.isEmpty || value == "$(EBIRD_API_TOKEN)" {
      return nil
    }

    return value
  }

  private static func uniqueObservations(from ebirdObservations: [EbirdNotableObservation]) -> [Obs] {
    var seen = Set<String>()

    return ebirdObservations.enumerated().compactMap { index, observation in
      let uniqueKey = observation.obsId ?? "\(observation.subId ?? "")-\(observation.speciesCode ?? "")"
      guard seen.insert(uniqueKey).inserted else { return nil }
      return observation.asObservation(index: index)
    }
  }
}

// swiftlint:disable function_body_length
extension EbirdNotableObservation {
  func asObservation(index: Int) -> Obs {
    let parsedDateTime = parseObservationDateTime(obsDt)
    let location = LocationDetail(
      id: index,
      name: locName ?? "",
      countryCode: "NL",
      permalink: locId ?? ""
    )
    let species = SpeciesDetail(
      id: 0,
      scientificName: sciName ?? "",
      name: comName ?? speciesCode ?? "",
      group: 1
    )
    let noteParts = [
      obsReviewed == true ? "Reviewed" : nil,
      obsValid == true ? "Valid" : nil,
      subId
    ].compactMap { $0 }
    let numericID = numericObservationID(fallback: index)
    let userDetail = UserDetail(
      id: numericID,
      name: userDisplayName ?? "",
      avatar: nil
    )

    return Obs(
      idObs: numericID,
      species: nil,
      date: parsedDateTime.date,
      time: parsedDateTime.time,
      number: howMany ?? 1,
      sex: "",
      point: Point(type: "Point", coordinates: [lng ?? 0, lat ?? 0]),
      accuracy: nil,
      notes: noteParts.isEmpty ? nil : noteParts.joined(separator: " - "),
      isCertain: obsValid ?? false,
      isEscape: false,
      activity: 0,
      lifeStage: 0,
      method: nil,
      substrate: nil,
      relatedSpecies: nil,
      obscurity: nil,
      hasPhoto: hasRichMedia == true || evidence == "P",
      hasSound: false,
      countingMethod: nil,
      embargoDate: nil,
      uuid: subId,
      externalReference: subId,
      observerLocation: nil,
      transectUUID: nil,
      speciesDetail: species,
      rarity: 4,
      user: numericID,
      userDetail: userDisplayName == nil ? nil : userDetail,
      modified: nil,
      speciesGroup: 1,
      validationStatus: obsValid == true ? "valid" : "",
      location: nil,
      locationDetail: location,
      photos: nil,
      sounds: nil,
      permalink: subId.map { "https://ebird.org/checklist/\($0)" } ?? "",
      detail: nil,
      code: speciesCode,
      timeDate: parsedDateTime.dateValue
    )
  }

  private func parseObservationDateTime(_ value: String?) -> (date: String, time: String?, dateValue: Date?) {
    guard let value = value else {
      return ("2023-01-01", nil, nil)
    }

    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")

    for dateFormat in ["yyyy-MM-dd HH:mm", "yyyy-MM-dd HH:mm:ss"] {
      formatter.dateFormat = dateFormat
      if let dateValue = formatter.date(from: value) {
        let time = value.count >= 16 ? String(value.dropFirst(11).prefix(5)) : nil
        return (String(value.prefix(10)), time, dateValue)
      }
    }

    return (String(value.prefix(10)), nil, nil)
  }

  private func numericObservationID(fallback: Int) -> Int {
    let sourceID = obsId ?? subId ?? speciesCode ?? "\(fallback)"
    let digits = sourceID.filter(\.isNumber)

    if let id = Int(digits), id > 0 {
      return id
    }

    return abs(sourceID.hashValue)
  }
}
// swiftlint:enable function_body_length

struct EbirdNotableObservationsView: View {
  @StateObject private var viewModel = EbirdNotableObservationsViewModel()

  @EnvironmentObject var settings: Settings

  @Binding var selectedSpeciesID: Int?

  @State private var currentSortingOption: SortingOption? = .date
  @State private var currentFilteringAllOption: FilterAllOption? = .all
  @State private var currentFilteringOption: FilteringRarityOption? = .all
  @State private var timePeriod: TimePeriod? = .week

  var body: some View {
    VStack {
      if showView { Text("EbirdNotableObservationsView").font(.customTiny) }

      HStack {
        Text("eBird notable observations")
          .bold()
        Spacer()
      }
      .padding(.horizontal, 10)

      HStack {
        ObservationsCountView(count: viewModel.count)
        Text("in")
          .font(.caption)
          .foregroundColor(.gray)
          .bold()
        ObservationsTimePeriodView(timePeriod: .week)
        Spacer()
      }
      .padding(.horizontal, 10)

      HorizontalLine()

      if viewModel.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let observations = viewModel.observations, !observations.isEmpty {
        ObservationListView(
          observations: observations,
          selectedSpeciesID: $selectedSpeciesID,
          timePeriod: $timePeriod,
          entity: .ebird,
          currentSortingOption: $currentSortingOption,
          currentFilteringAllOption: $currentFilteringAllOption,
          currentFilteringOption: $currentFilteringOption
        )
      } else {
        VStack(spacing: 12) {
          NoObservationsView()
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .refreshable {
      viewModel.fetchData(settings: settings)
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if viewModel.observations == nil {
        viewModel.fetchData(settings: settings)
      }
    }
  }
}

struct ObservationsChartView: View {
  var observations: [Obs]
  var name: String = ""

  // Step 1: Group and count observations by DD-MM
  private var groupedObservations: [(date: String, count: Int)] {
    let grouped = Dictionary(grouping: observations, by: { dateToDayMonth($0.date) })
    return grouped.map { (date: $0.key, count: $0.value.count) }
      .sorted { $0.date < $1.date } // Ensure chronological order
  }

  // Extracts "DD-MM" from "YY-MM-DD"
  private func dateToDayMonth(_ fullDate: String) -> String {
    let components = fullDate.split(separator: "-")
    guard components.count == 3 else { return fullDate }
    return "\(components[2])-\(components[1])"  // Extracts "DD-MM"
  }

  var body: some View {
    VStack {
      Text("Laatste \(observations.count) obs \(name)")
        .font(.caption)
        .padding()
      Chart {
        ForEach(groupedObservations, id: \.date) { entry in
          BarMark(
            x: .value("Date", entry.date),
            y: .value("Observations", entry.count)
          )
        }
      }
      .rotationEffect(.degrees(90)) // Rotate chart
      .frame(height: 300)
      .frame(width: 500)
      .padding()
    }
  }
}
