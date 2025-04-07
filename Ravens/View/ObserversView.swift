//
//  ObserversView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/12/2024.
//

import SwiftUI
import SwiftyBeaver

struct IdentifiableString: Identifiable {
  var id: String { self.value }
  var value: String
  var name: String
}

struct ObserversView: View {
  let log = SwiftyBeaver.self

  @ObservedObject var observationUser: ObservationsViewModel

  @EnvironmentObject private var observersViewModel: ObserversViewModel
  @EnvironmentObject private var userViewModel: UserViewModel

  @EnvironmentObject private var settings: Settings
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  @State private var showingShareSheet = false
  @State private var showingQRCodeSheet = false
  @State private var textToShare: String = "your text"
  @State var QRCode: IdentifiableString?
  @State private var userName: String = "unknown"

  @Binding var observerId: Int
  @Binding var observerName: String?

  @State var addObserver: Bool = false

  var body: some View {
    NavigationStack {
      VStack {
        if showView { Text("ObserversView").font(.customTiny) }
        Form {
          Section {
            HStack {
              Button(demo ? names[11] : userViewModel.user?.name ?? "") {
                observerId = userViewModel.user?.id ?? 0
                observerName = userViewModel.user?.name ?? ""
                self.presentationMode.wrappedValue.dismiss()
              }

              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(action: {
                  QRCode = IdentifiableString(
                    value: "ravens://\(cleanName(userViewModel.user?.name ?? ""))/\(userViewModel.user?.id ?? 0)",
                    name: userViewModel.user?.name ?? "")
                  showingQRCodeSheet = true
                }) {
                  Image(systemName: "qrcode")
                }

                Button(action: {
                  if let url = URL(string: "https://waarneming.nl/users/\(userViewModel.user?.id ?? 0)/") {
                    UIApplication.shared.open(url)
                  }
                }) {
                  Image(systemSymbol: SFObservation)
                }
                .tint(.obsObservation)
              }

              Spacer()
              if (observerId) == (userViewModel.user?.id ?? 0) {
                Image(systemName: "checkmark").foregroundColor(.blue) }
            }
          }
          Section {
            List {
              // all other saved observers
              ForEach(Array(observersViewModel.records.sorted(by: { $0.name < $1.name }).enumerated()), id: \.element.id) { index, record in
                HStack {
                  Button(demo ? names[index] : record.name) {
                    observerId = record.userID
                    observerName = record.name
                    self.presentationMode.wrappedValue.dismiss()
                  }
                  Spacer()
                  if (observerId) == (record.userID) {
                    Image(systemName: "checkmark").foregroundColor(.blue) }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                  Button(action: {
                    QRCode = IdentifiableString(
                      value: "ravens://\(cleanName(record.name))/\(record.userID)",
                      name: record.name)
                    showingQRCodeSheet = true
                  }) {
                    Image(systemName: "qrcode")
                  }
                  
                  URLShareButtonView(urlShare: "ravens://\(cleanName(record.name))/\(record.userID)")

                  Button(action: {
                    observersViewModel.removeRecord(userID: record.userID)
                    observerId = userViewModel.user?.id ?? 0
                    observerName = userViewModel.user?.name ?? ""

                  }) {
                    Label("remove", systemImage: "person.fill.badge.minus")
                  }
                  .tint(.red)

                  Button(action: {
                    if let url = URL(string: "https://waarneming.nl/users/\(record.userID)/") {
                      UIApplication.shared.open(url)
                    }
                  }) {
                    Image(systemSymbol: SFObservation)
                  }
                  .tint(.obsObservation)
                }
              }
            }
          }
        }
      }
    }
    .onAppear {
      observersViewModel.loadRecords()
    }
    .sheet(item: $QRCode) { item in
      VStack {
        Text(item.name)
          .font(.title)
        Text(item.id)
          .font(.caption)
          .foregroundColor(.secondary)
        QRCodeView(input: item.value)
          .frame(width: 200, height: 200)
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
  }
}
