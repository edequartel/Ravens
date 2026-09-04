//
//  SettingsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 09/01/2024.
//

import SwiftUI
import SwiftyBeaver

struct SettingsView: View {
  let log = SwiftyBeaver.self
  @Environment(\.locale) private var locale
  @EnvironmentObject var speciesViewModel: SpeciesViewModel
  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var regionsViewModel: RegionsViewModel
  @EnvironmentObject var regionListViewModel: RegionListViewModel
  @EnvironmentObject var accessibilityManager: AccessibilityManager
  @EnvironmentObject var settings: Settings

  @State private var storage: String = ""

  let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

  let minimumRadius = 500.0
  let maximumRadius = 10000.0
  let step = 500.0

  var body: some View {
    NavigationStack {
//      LiveLogView()
      
      List {
        Section(header: Text("Ravens")) {
          NavigationLink(destination: LoginView()) {
            Text("Login \(settings.selectedInBetween)")
          }
        }

        Section(header: Text(source)) {
          Picker(source, selection: $settings.selectedInBetween) {
            Text("waarneming.nl")
              .tag("waarneming.nl")
            Text("observation.org")
              .tag("observation.org")
          }
          .pickerStyle(.inline)
          .onChange(of: settings.selectedInBetween) {
          }
        }

        Section {
          LanguageView()
        }

//        Section {
//          RegionsView()
//        }

//        Section {//!!
//          RegionListView()
//        }

//        Section { // THIS A DEVELOPER BUTTON TO SEE WHICH FILES ARE IN DE ICLOUD HIDDEN
//          Button("iCloud content") {
//            let fileManager = FileManager.default
//            if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil)?
//                .appendingPathComponent("Documents") {
//                let files = try? fileManager.contentsOfDirectory(at: ubiquityURL, includingPropertiesForKeys: nil)
//                print("iCloud files:", files ?? [])
//            }
//          }
//        }

        Section(header: Text(map)) {
          Picker("Map Style", selection: $settings.mapStyleChoice) {
            ForEach(MapStyleChoice.allCases, id: \.self) { choice in
              Text(choice.localized).tag(choice)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
        }

        Section {
          NavigationLink(destination: ColofonView()) {
            Label("Colofon", systemImage: "info.circle")
          }
          .accessibilityLabel("Colofon")
        }

        Section(header: Text(appDetails)) {
          VStack(alignment: .leading) {
            Text(version())
            Text(locale.description)
            Text(accessibilityManager.isVoiceOverEnabled ? "VoiceOver is ON" : "VoiceOver is OFF")
          }
          .font(.footnote)
          .padding(4)
          .accessibilityElement(children: .combine)
        }
      }
      .navigationTitle(settingsName)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if let url = URL(string: "https://www.tastenbraille.com/ravens/index.php") {
//            if let url = URL(string: "https://edequartel.github.io/Ravens/") {
              UIApplication.shared.open(url)
            }
          }) {
            Image(systemName: "link")
              .uniformSize()
              .accessibilityLabel(information)
          }
        }
      }
    }
  }

  func getId(region: Int, speciesGroup: Int) -> Int? {
    log.verbose("getID from regionListViewModel region: \(region) species_group: \(speciesGroup)")
    if let matchingItem = regionListViewModel.regionLists.first(
      where: { $0.region == region && $0.speciesGroup == speciesGroup }) {
      log.error("getId= \(matchingItem)")
      return matchingItem.id
    }
    log.error("getId: NIL")
    return nil
  }

  func getGroup(id: Int) -> String? {
    log.error("getGroup: \(id)")
    if let matchingItem = speciesGroupsViewModel.speciesGroups.first(
      where: { $0.id==id }) {
      log.error("getGroup= \(matchingItem)")
      return matchingItem.name
    }
    log.error("getGroup: NIL")
    return nil
  }

  func version() -> String {
    guard let dictionary = Bundle.main.infoDictionary,
          let version = dictionary["CFBundleShortVersionString"] as? String,
          let build = dictionary["CFBundleVersion"] as? String else {
      return "Version information not available"
    }
    return "Version \(version) build \(build)"
  }
}

struct ColofonView: View {
  private let dataSources = [
    ColofonItem(
      title: "Waarneming.nl / Observation.org",
      detail: "Waarnemingen, soortnamen, locaties en soortgroepen.",
      url: "https://waarneming.nl"
    ),
    ColofonItem(
      title: "GBIF",
      detail: "Taxonomische naamcontrole, accepted names en synoniemen.",
      url: "https://www.gbif.org"
    ),
    ColofonItem(
      title: "iNaturalist",
      detail: "Aanvullende soortfoto's wanneer een waarneming geen foto heeft.",
      url: "https://www.inaturalist.org"
    ),
    ColofonItem(
      title: "Xeno-canto",
      detail: "Vogelgeluiden en geluidsmetadata.",
      url: "https://xeno-canto.org"
    )
  ]

  private let packages = [
    ColofonItem(
      title: "Alamofire",
      detail: "Netwerkverzoeken.",
      url: "https://github.com/Alamofire/Alamofire"
    ),
    ColofonItem(
      title: "AlamofireImage",
      detail: "Afbeeldingen laden en verwerken.",
      url: "https://github.com/Alamofire/AlamofireImage"
    ),
    ColofonItem(
      title: "Kingfisher",
      detail: "Afbeeldingen downloaden en cachen.",
      url: "https://github.com/onevcat/Kingfisher"
    ),
    ColofonItem(
      title: "SwiftAudioEx",
      detail: "Audio afspelen.",
      url: "https://github.com/doublesymmetry/SwiftAudioEx"
    ),
    ColofonItem(
      title: "SwiftSoup",
      detail: "HTML uitlezen.",
      url: "https://github.com/scinfu/SwiftSoup"
    ),
    ColofonItem(
      title: "Swift Markdown UI",
      detail: "Markdown tonen in SwiftUI.",
      url: "https://github.com/gonzalezreal/swift-markdown-ui"
    ),
    ColofonItem(
      title: "RichText",
      detail: "Rijke tekstweergave.",
      url: "https://github.com/NuPlay/RichText"
    ),
    ColofonItem(
      title: "SFSafeSymbols",
      detail: "Veilig gebruik van SF Symbols.",
      url: "https://github.com/SFSafeSymbols/SFSafeSymbols"
    ),
    ColofonItem(
      title: "KeychainAccess",
      detail: "Opslag van gevoelige instellingen.",
      url: "https://github.com/kishikawakatsumi/KeychainAccess"
    ),
    ColofonItem(
      title: "Lottie",
      detail: "Animaties.",
      url: "https://github.com/airbnb/lottie-ios"
    ),
    ColofonItem(
      title: "SVGView",
      detail: "SVG-afbeeldingen tonen.",
      url: "https://github.com/exyte/SVGView"
    ),
    ColofonItem(
      title: "WaterfallGrid",
      detail: "Rasterweergave voor fotolijsten.",
      url: "https://github.com/paololeonardi/WaterfallGrid"
    ),
    ColofonItem(
      title: "LazyPager",
      detail: "Bladerbare detailweergaves.",
      url: "https://github.com/gh123man/LazyPager"
    ),
    ColofonItem(
      title: "MijickCalendarView",
      detail: "Kalenderweergave.",
      url: "https://github.com/Mijick/CalendarView"
    ),
    ColofonItem(
      title: "NetworkImage",
      detail: "Afbeeldingen via netwerk tonen.",
      url: "https://github.com/gonzalezreal/NetworkImage"
    ),
    ColofonItem(
      title: "SwiftUIImageViewer",
      detail: "Afbeeldingen vergroot bekijken.",
      url: "https://github.com/fuzzzlove/swiftui-image-viewer"
    ),
    ColofonItem(
      title: "SwiftLintPlugins",
      detail: "Codecontrole tijdens het bouwen.",
      url: "https://github.com/SimplyDanny/SwiftLintPlugins"
    ),
    ColofonItem(
      title: "SwiftyBeaver",
      detail: "Logging.",
      url: "https://github.com/SwiftyBeaver/SwiftyBeaver"
    )
  ]

  var body: some View {
    List {
      Section("Ravens") {
        Text("Ravens gebruikt gegevens, media en open-source software van meerdere externe bronnen en contributors.")
          .font(.footnote)
          .foregroundColor(.secondary)
      }

      Section("Data en media") {
        ForEach(dataSources) { item in
          ColofonLinkRow(item: item)
        }
      }

      Section("Open-source packages") {
        ForEach(packages) { item in
          ColofonLinkRow(item: item)
        }
      }

      Section("Dank") {
        Text("Dank aan alle waarnemers, geluidsrecordisten, fotografen, databeheerders en open-source maintainers die Ravens mogelijk maken.")
          .font(.footnote)
          .foregroundColor(.secondary)
      }
    }
    .navigationTitle("Colofon")
    .navigationBarTitleDisplayMode(.inline)
  }
}

private struct ColofonItem: Identifiable {
  let id = UUID()
  let title: String
  let detail: String
  let url: String
}

private struct ColofonRow: View {
  let item: ColofonItem

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(item.title)
        .foregroundColor(.primary)
      Text(item.detail)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
  }
}

private struct ColofonLinkRow: View {
  let item: ColofonItem

  var body: some View {
    Button {
      if let url = URL(string: item.url) {
        UIApplication.shared.open(url)
      }
    } label: {
      HStack(spacing: 12) {
        ColofonRow(item: item)
        Spacer()
        Image(systemName: "safari")
          .foregroundColor(.secondary)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityHint("Opent de link in de browser")
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    // Setting up the environment objects for the preview
    SettingsView()
      .environmentObject(Settings())
  }
}

struct AIPromptOption: Identifiable {
  let id: String
  let titleKey: String
  let prompt: String
}

struct AIPromptSettingsView: View {
  @EnvironmentObject var settings: Settings
  @State private var filterText = ""

  private var promptOptions: [AIPromptOption] {
    [
      AIPromptOption(id: "etymology", titleKey: "aiPromptEtymologyTitle", prompt: String(localized: "aiChat")),
      AIPromptOption(id: "taxonomy", titleKey: "aiPromptTaxonomyTitle", prompt: String(localized: "aiPromptTaxonomy")),
      AIPromptOption(id: "ecology", titleKey: "aiPromptEcologyTitle", prompt: String(localized: "aiPromptEcology")),
      AIPromptOption(id: "biology", titleKey: "aiPromptBiologyTitle", prompt: String(localized: "aiPromptBiology")),
      AIPromptOption(id: "profile", titleKey: "aiPromptProfileTitle", prompt: String(localized: "aiPromptProfile"))
    ]
  }

  private var filteredPromptOptions: [AIPromptOption] {
    let filter = filterText.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !filter.isEmpty else {
      return promptOptions
    }

    return promptOptions.filter {
      NSLocalizedString($0.titleKey, comment: "").localizedCaseInsensitiveContains(filter) ||
      $0.prompt.localizedCaseInsensitiveContains(filter)
    }
  }

  var body: some View {
    List {
      Section(header: Text("AI prompt")) {
        TextEditor(text: $settings.aiChatPrompt)
          .frame(minHeight: 120)
          .autocorrectionDisabled()

        TextField("Filter", text: $filterText)
          .autocorrectionDisabled()
      }

      Section {
        ForEach(filteredPromptOptions) { promptOption in
          Button {
            settings.aiChatPrompt = promptOption.prompt
            filterText = ""
          } label: {
            HStack(alignment: .top) {
              VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(promptOption.titleKey))
                  .font(.headline)
                Text(promptOption.prompt)
                  .font(.footnote)
                  .foregroundColor(.secondary)
              }
              Spacer()
              if settings.aiChatPrompt == promptOption.prompt {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }

      Section {
        Button("Reset") {
          settings.aiChatPrompt = String(localized: "aiChat")
          filterText = ""
        }
      }
    }
    .navigationTitle("AI prompt")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct AIPromptShareButton: View {
  @EnvironmentObject var settings: Settings
  @State private var showPromptSettings = false

  let speciesName: String

  var body: some View {
    ShareLink(item: settings.aiPromptMessage(for: speciesName)) {
      Image(systemName: "brain.head.profile")
        .uniformSize()
    }
    .simultaneousGesture(
      LongPressGesture(minimumDuration: 0.5)
        .onEnded { _ in
          showPromptSettings = true
        }
    )
    .sheet(isPresented: $showPromptSettings) {
      NavigationStack {
        AIPromptSettingsView()
      }
    }
  }
}

struct SpeciesGroupPickerView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var speciesGroupsViewModel: SpeciesGroupsViewModel
  @EnvironmentObject var regionsViewModel: RegionsViewModel
  @EnvironmentObject var regionListViewModel: RegionListViewModel
  @EnvironmentObject var settings: Settings

  @Binding var currentSpeciesGroup: Int?

  var entity: EntityType

  var body: some View {
    Section(header: Text(species)) {
      if showView { Text("SpeciesGroupPickerView").font(.customTiny) }
      Picker(group, selection: $currentSpeciesGroup) {
        ForEach( entity != .species ? speciesGroupsViewModel.speciesGroupsAll : speciesGroupsViewModel.speciesGroups, id: \ .id) { speciesGroup in

          // only at speciesList we will look if the getId exists for user, radius and location not
          if (entity != .species) || (regionListViewModel.getId(region: settings.selectedRegionId, speciesGroup: speciesGroup.id) ?? -1 > 0) {
            if speciesGroup.id != -1 {
              Text("\(speciesGroup.name)")// \(speciesGroup.id)") // ?? picture svg
                .tag(speciesGroup.id)
                .lineLimit(1)
                .truncationMode(.tail)
            } else {
              Image(systemSymbol: .infinity)
                .tag(speciesGroup.id)
            }
          }
        }
      }
      .pickerStyle(.navigationLink)
      .onChange(of: settings.selectedLanguage) {
        speciesGroupsViewModel.fetchData(settings: settings)
      }
    }
  }
}

struct RadiusPickerView: View {
  @Binding var selectedRadius: Int // Binding for Int radius selection

  let radiusOptions = Array(stride(from: 1000, through: 10000, by: 1000)) // Int values

  var body: some View {
    VStack {
      Picker(radius, selection: $selectedRadius) {
        ForEach(radiusOptions, id: \.self) { radius in
          Text("\(Int(radius)) m").tag(radius) // Convert to Int for display
        }
      }
      .pickerStyle(.menu) // Wheel picker style
    }
  }
}
