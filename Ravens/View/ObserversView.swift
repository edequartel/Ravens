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

  @ObservedObject var observationUser : ObservationsViewModel

  @EnvironmentObject private var observersViewModel: ObserversViewModel
  @EnvironmentObject private var userViewModel:  UserViewModel

  @EnvironmentObject private var settings: Settings
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  @State private var showingShareSheet = false
  @State private var showingQRCodeSheet = false
  @State private var textToShare: String = "your text"
  @State var QRCode: IdentifiableString? = nil //deze moet identifiable zijn en nil anders wordt de sheet gelijk geopend
  @State private var userName: String = "unknown"

  @Binding var observerId: Int
  @Binding var observerName: String

  @State var addObserver: Bool = false

  var body: some View {
    VStack {
      if showView { Text("ObserversView").font(.customTiny) }
//      Text("\(userViewModel.user?.name ?? "")")
//        .bold()
//      Text("\(userViewModel.user?.id ?? 0)")
//        .font(.caption)
//        .foregroundColor(.secondary)

      Form {
        Section() {
          HStack {
            Button(userViewModel.user?.name ?? "") {
              observerId = userViewModel.user?.id ?? 0
              observerName = userViewModel.user?.name ?? ""
              self.presentationMode.wrappedValue.dismiss()
            }
            
//            .bold()
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


        Section () {
          List {
            //all other saved observers
            ForEach(observersViewModel.records.sorted { $0.name < $1.name }) { record in
              HStack{
                Button("\(record.name)") {
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
          .sheet(item: $QRCode) { item in
            VStack{
              Text(item.name)
                .font(.title)
              Text(item.id)
                .font(.caption)
                .foregroundColor(.secondary)
              QRCodeView(input: item.value)
                .frame(width: 200, height: 200)
            }
          }
        }
      }
      
    }
    .sheet(isPresented: $addObserver) {AddObserverView()}
    .onAppear {
      observersViewModel.loadRecords()
    }
  }
}

import SwiftUI

struct AddObserverView: View {
    @EnvironmentObject private var observersViewModel: ObserversViewModel
    @State private var name: String = ""
    @State private var userID: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .autocorrectionDisabled(true)
                .submitLabel(.next)

            TextField("ID", text: $userID)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .submitLabel(.done)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .bold()
            }

            Button("Add") {
                if validateInputs() {
                    if let id = Int(userID) {
                        observersViewModel.appendRecord(name: name, userID: id)
                        clearInputs()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || userID.isEmpty)
        }
        .padding()
        .navigationTitle("Add Observer")
        .navigationBarTitleDisplayMode(.inline)
        .onSubmit {
            // Automatically validate on keyboard "Return" action
            if validateInputs() {
                if let id = Int(userID) {
                    observersViewModel.appendRecord(name: name, userID: id)
                    clearInputs()
                }
            }
        }
    }

    private func validateInputs() -> Bool {
        errorMessage = ""

        // Check if name is non-empty and alphanumeric
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Name cannot be empty."
            return false
        }

        if !name.isAlphanumeric {
            errorMessage = "Name must be alphanumeric."
            return false
        }

        // Check if userID is non-empty and numeric
        if userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "ID cannot be empty."
            return false
        }

        if Int(userID) == nil {
            errorMessage = "ID must be a numeric value."
            return false
        }

        return true
    }

    private func clearInputs() {
        name = ""
        userID = ""
    }
}

extension String {
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "^[a-zA-Z0-9 ]+$", options: .regularExpression) != nil
    }
}


import Alamofire

/// Checks if a URL exists by performing a HEAD request.
/// - Parameters:
///   - urlString: The URL string to check.
///   - completion: A closure that returns `true` if the URL exists, `false` otherwise.
func checkIfURLExists(urlString: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(false)
        return
    }

    // Perform a HEAD request using Alamofire
    AF.request(url, method: .head).validate().response { response in
        if let httpResponse = response.response {
            // Return true if the status code is in the 200-299 range
            completion((200...299).contains(httpResponse.statusCode))
        } else {
            // Return false for any error or invalid response
            completion(false)
        }
    }
}


import SwiftUI

struct URLCheckerView: View {
    @State private var urlToCheck: String = ""
    @State private var resultText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter URL", text: $urlToCheck)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Check URL") {
                isLoading = true
                resultText = ""
                checkIfURLExists(urlString: urlToCheck) { exists in
                    isLoading = false
                    resultText = exists ? "URL exists!" : "URL does not exist!"
                }
            }
            .disabled(urlToCheck.isEmpty)
            .padding()

            if isLoading {
                ProgressView()
            } else {
                Text(resultText)
                    .foregroundColor(resultText == "URL exists!" ? .green : .red)
            }
        }
        .padding()
    }
}

//https://waarneming.nl/users/135496/
