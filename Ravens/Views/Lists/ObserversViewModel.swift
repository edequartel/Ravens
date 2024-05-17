//
//  RecordsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/05/2024.
//

import Foundation

struct Observer: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
    var name: String
    var group: String?
    var userID: Int
}

class URLHandler: ObservableObject {
    @Published var urlString: String = ""
}

class ObserversViewModel: ObservableObject {
    @Published var records: [Observer] = []
    let filePath: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("observers.json")
        
        loadRecords()
    }
    
    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Observer].self, from: data)
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: filePath, options: .atomicWrite)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func isObserverInRecords(userID: Int) -> Bool {
        return records.contains(where: { $0.userID == userID })
    }
    
    func appendRecord(name: String, userID: Int) {
        guard !records.contains(where: { $0.userID == userID }) else {
            print("Record with userID \(userID) already exists.")
            return
        }
        let newRecord = Observer(name: name, userID: userID)
        records.append(newRecord)
        saveRecords()
    }
    
    func removeRecord(userID: Int) {
        if let index = records.firstIndex(where: { $0.userID == userID }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with userID \(userID) does not exist.")
        }
    }
}

import SwiftUI

struct IdentifiableString: Identifiable {
    var id: String { self.value }
    var value: String
    var name: String
}

struct ObserversView: View {
    @EnvironmentObject private var viewModel: ObserversViewModel
    @EnvironmentObject private var userViewModel:  UserViewModel
    @EnvironmentObject private var settings: Settings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showingShareSheet = false
    @State private var showingQRCodeSheet = false
    @State private var textToShare: String = "your text"
    @State var QRCode: IdentifiableString? = nil //deze moet identifiable zijn en nil anders wordt de sheer gelijk geopend
    @State private var userName: String = "unknown"
    
    @State private var newName = ""
    @State private var newUserID = ""
    
    var body: some View {
            VStack {
                List {
                    Text("\(userViewModel.user?.name ?? "unknown")")
                        .onTapGesture {
                            settings.userId = userViewModel.user?.id ?? 0
                            settings.userName = userViewModel.user?.name ?? "unknown"
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                textToShare = "ravens://\(userViewModel.user?.id ?? 0)/\(userViewModel.user?.name ?? "unknown")"
                                showingShareSheet = true
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(.obsGreenEagle)
                            
                            Button(action: {
                                QRCode = IdentifiableString(
                                    value: "ravens://\(userViewModel.user?.name ?? "unknown")/\(userViewModel.user?.id ?? 0)",
                                    name: userViewModel.user?.name ?? "unknown")
                                showingQRCodeSheet = true
                            }) {
                                Label("QRCode", systemImage: "qrcode")
                            }
                            .tint(.gray)
     
                        }
                        .foregroundColor((settings.userId == userViewModel.user?.id ?? 0) ? Color.blue : Color.primary)
                    
                    
                    ForEach(viewModel.records) { record in
                        HStack{
                            Text("\(record.name) (\(record.userID))")
                            Spacer()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                textToShare = "ravens://\(record.name)/\(record.userID)"
                                print("sharetext: \(textToShare)")
                                showingShareSheet = true
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(.obsGreenEagle)
                            
                            Button(action: {
                                viewModel.removeRecord(userID: record.userID)
                            }) {
                                Label("remove", systemImage: "person.fill.badge.minus")
                            }
                            .tint(.red)
                            
                            Button(action: {
                                QRCode = IdentifiableString(
                                    value: "ravens://\(record.name)/\(record.id)",
                                    name: record.name)
                                showingQRCodeSheet = true
                            }) {
                                Label("QRCode", systemImage: "qrcode")
                            }
                            .tint(.gray)
                        }

                        .onTapGesture {
                            settings.userId = record.userID
                            settings.userName = record.name
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(record.userID == settings.userId ? Color.blue : Color.primary)
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
                
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(items: [self.textToShare])
                }
                

            }
        .onAppear {
            viewModel.loadRecords()
        }
    }
}
