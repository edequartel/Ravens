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

    @EnvironmentObject private var observersViewModel: ObserversViewModel
    @EnvironmentObject private var userViewModel:  UserViewModel
    @EnvironmentObject private var observationsViewModel: ObservationsViewModel
    @EnvironmentObject private var settings: Settings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showingShareSheet = false
    @State private var showingQRCodeSheet = false
    @State private var textToShare: String = "your text"
    @State var QRCode: IdentifiableString? = nil //deze moet identifiable zijn en nil anders wordt de sheet gelijk geopend
    @State private var userName: String = "unknown"


    var body: some View {
        VStack {
          if showView { Text("ObserversView").font(.customTiny) }
            List {
                HStack {
                    Button(userViewModel.user?.name ?? "") {
                        settings.userId = userViewModel.user?.id ?? 0
                        settings.userName =  userViewModel.user?.name ?? ""

                        observationsViewModel.fetchData(
                            settings: settings,
//                            entityType: "user",
                            userId: userViewModel.user?.id ?? 0,
                            completion: { log.info("observationsUserViewModel.fetchdata \(userViewModel.user?.id ?? 0)") })

                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(userViewModel.user?.id ?? 0 == settings.userId ? Color.blue : Color.primary)
                    .bold()
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
                }


                ForEach(observersViewModel.records.sorted { $0.name < $1.name }) { record in
                    HStack{
                        Button(record.name) {
                            settings.userId = record.userID
                            settings.userName =  record.name

                            observationsViewModel.fetchData(
                                settings: settings,
//                                entityType: "user",
                                userId: record.userID,
                                completion: { log.info("observationsUserViewModel.fetchdata \(record.userID)") }
                                )

                            self.presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
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



                      Button(action: {
                        observersViewModel.removeRecord(userID: record.userID)
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
            .sheet(item: $QRCode) { item in
                VStack{
                    Text(item.name)
                        .font(.title)
                    QRCodeView(input: item.value)
                        .frame(width: 200, height: 200)
                }
            }
        }
        .onAppear {
            observersViewModel.loadRecords()
        }
    }
}


