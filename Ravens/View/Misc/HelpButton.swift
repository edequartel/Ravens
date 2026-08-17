//
//  HelpButton.swift
//  Ravens
//

import SwiftUI

enum RavensHelp {
  static let speciesSearch = "Zoek een soort op Nederlandse of wetenschappelijke naam."
  static let scientificName = "De internationaal gebruikte wetenschappelijke naam van de soort."
  static let nativeName = "De Nederlandse naam van de soort zoals die in de gekozen bron wordt gebruikt."
  static let observations = "Toont waarnemingen binnen de gekozen periode, soortgroep en filters."
  static let location = "Gebruikt een gebied of je huidige locatie om waarnemingen in de buurt te tonen."
  static let dateTime = "Datum en tijd waarop de waarneming is doorgegeven."
  static let photo = "Toont foto's bij de waarneming. Als er geen foto is, kan Ravens een soortfoto via iNaturalist tonen."
  static let sound = "Toont beschikbare geluidsopnamen van deze vogel via Xeno-canto of geluiden bij de waarneming."
  static let source = "Kies welke waarnemingenbron Ravens gebruikt voor soortinformatie en waarnemingen."
  static let waarneming = "Waarneming.nl levert de Nederlandse waarnemingen en soortgegevens."
  static let iNaturalist = "iNaturalist wordt gebruikt als aanvullende bron voor soortfoto's."
  static let xenoCanto = "Xeno-canto levert vogelgeluiden. Ravens probeert ook alternatieve taxonomische namen als een naam geen resultaten geeft."
  static let taxonomy = "Taxonomie helpt wanneer bronnen verschillende wetenschappelijke namen gebruiken voor dezelfde soort."
  static let favorites = "Met favorieten kun je soorten, gebieden of waarnemers sneller terugvinden."
  static let settings = "Hier stel je bron, taal, kaartstijl en andere voorkeuren voor Ravens in."
  static let filters = "Filters bepalen welke waarnemingen zichtbaar zijn, bijvoorbeeld periode, soortgroep, zeldzaamheid en sortering."
  static let apiOptions = "Deze keuze bepaalt welke externe bron Ravens raadpleegt voor gegevens."
  static let aiPrompt = "Pas de standaardprompt aan die wordt gedeeld met je AI-app."

  static let speciesSearchItems = [
    RavensHelpItem(title: "Soort zoeken", text: speciesSearch),
    RavensHelpItem(title: "Nederlandse naam", text: nativeName),
    RavensHelpItem(title: "Wetenschappelijke naam", text: scientificName),
    RavensHelpItem(title: "Favorieten", text: favorites),
    RavensHelpItem(title: "Filters", text: filters)
  ]

  static let speciesObservationItems = [
    RavensHelpItem(title: "Waarnemingen", text: observations),
    RavensHelpItem(title: "Periode", text: filters),
    RavensHelpItem(title: "Geluid", text: xenoCanto),
    RavensHelpItem(title: "Taxonomie", text: taxonomy),
    RavensHelpItem(title: "Soortinformatie", text: scientificName)
  ]

  static let observationDetailItems = [
    RavensHelpItem(title: "Nederlandse naam", text: nativeName),
    RavensHelpItem(title: "Wetenschappelijke naam", text: scientificName),
    RavensHelpItem(title: "Datum en tijd", text: dateTime),
    RavensHelpItem(title: "Locatie", text: location),
    RavensHelpItem(title: "Foto", text: photo),
    RavensHelpItem(title: "Geluid", text: sound)
  ]

  static let locationItems = [
    RavensHelpItem(title: "Locatie", text: location),
    RavensHelpItem(title: "Waarnemingen", text: observations),
    RavensHelpItem(title: "Filters", text: filters),
    RavensHelpItem(title: "Waarneming.nl", text: waarneming)
  ]

  static let radiusItems = [
    RavensHelpItem(title: "Locatie", text: location),
    RavensHelpItem(title: "Afstand", text: "De straal bepaalt hoe ver rondom je huidige positie waarnemingen worden opgehaald."),
    RavensHelpItem(title: "Waarnemingen", text: observations),
    RavensHelpItem(title: "Filters", text: filters)
  ]

  static let userItems = [
    RavensHelpItem(title: "Waarnemingen", text: observations),
    RavensHelpItem(title: "Waarnemer", text: "Kies een waarnemer om diens waarnemingen te bekijken."),
    RavensHelpItem(title: "Favorieten", text: favorites),
    RavensHelpItem(title: "Filters", text: filters)
  ]

  static let xenoCantoItems = [
    RavensHelpItem(title: "Xeno-canto", text: xenoCanto),
    RavensHelpItem(title: "Geluidstype", text: "Filter geluidsopnamen op type, zoals zang of roep."),
    RavensHelpItem(title: "Taxonomie", text: taxonomy)
  ]

  static let settingsItems = [
    RavensHelpItem(title: "Instellingen", text: settings),
    RavensHelpItem(title: "Bron", text: source),
    RavensHelpItem(title: "Waarneming.nl", text: waarneming),
    RavensHelpItem(title: "API", text: apiOptions),
    RavensHelpItem(title: "Kaartstijl", text: "Kies hoe kaarten standaard worden weergegeven.")
  ]

  static let filterItems = [
    RavensHelpItem(title: "Periode", text: filters),
    RavensHelpItem(title: "Soortgroep", text: "Beperk de lijst tot een soortgroep, zoals vogels of planten."),
    RavensHelpItem(title: "Sorteren", text: "Bepaalt de volgorde van de waarnemingen."),
    RavensHelpItem(title: "Zeldzaamheid", text: "Toont alleen waarnemingen met de gekozen zeldzaamheidsstatus.")
  ]

  static let aiPromptItems = [
    RavensHelpItem(title: "AI prompt", text: aiPrompt),
    RavensHelpItem(title: "Filter", text: "Filter de voorbeeldprompts en tik op een optie om die als standaard te gebruiken.")
  ]
}

struct RavensHelpItem: Identifiable {
  let id = UUID()
  let title: String
  let text: String
}

struct HelpOverlayButton: View {
  @Binding var isPresented: Bool

  var body: some View {
    Button {
      isPresented = true
    } label: {
      Image(systemName: "questionmark.circle")
        .imageScale(.medium)
        .frame(width: 32, height: 32)
        .contentShape(Rectangle())
    }
    .accessibilityLabel("Help")
    .accessibilityHint("Toont uitleg over deze functie")
  }
}

struct RavensHelpOverlay: View {
  let title: String
  let items: [RavensHelpItem]
  let close: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.28)
        .ignoresSafeArea()
        .onTapGesture(perform: close)

      VStack(alignment: .leading, spacing: 14) {
        HStack {
          Text(title)
            .font(.headline)
          Spacer()
          Button(action: close) {
            Image(systemName: "xmark.circle.fill")
              .imageScale(.large)
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Sluit help")
        }

        ForEach(items) { item in
          VStack(alignment: .leading, spacing: 3) {
            Text(item.title)
              .font(.subheadline)
              .bold()
            Text(item.text)
              .font(.callout)
              .foregroundColor(.secondary)
              .fixedSize(horizontal: false, vertical: true)
          }
          .accessibilityElement(children: .combine)
        }
      }
      .padding(16)
      .frame(maxWidth: 320, alignment: .leading)
      .background(.regularMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(radius: 12)
      .padding()
    }
    .transition(.opacity.combined(with: .scale(scale: 0.98)))
  }
}

struct RavensHelpOverlayModifier: ViewModifier {
  let title: String
  let items: [RavensHelpItem]
  @Binding var isPresented: Bool

  func body(content: Content) -> some View {
    ZStack {
      content
      if isPresented {
        RavensHelpOverlay(title: title, items: items) {
          withAnimation(.easeOut(duration: 0.18)) {
            isPresented = false
          }
        }
        .zIndex(1)
      }
    }
    .animation(.easeOut(duration: 0.18), value: isPresented)
  }
}

extension View {
  func ravensHelpOverlay(
    title: String,
    items: [RavensHelpItem],
    isPresented: Binding<Bool>
  ) -> some View {
    modifier(RavensHelpOverlayModifier(title: title, items: items, isPresented: isPresented))
  }
}
