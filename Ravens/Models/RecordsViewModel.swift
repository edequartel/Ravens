//
//  RecordsViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/05/2024.
//

import Foundation

struct Record: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
    var name: String
    var userID: String
}


import SwiftUI

class RecordsViewModel: ObservableObject {
    @Published var records: [Record] = []
    let filePath: URL

    init() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("records.json")
        
        loadRecords()
    }

    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Record].self, from: data)
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

    func appendRecord(name: String, userID: String) {
        guard !records.contains(where: { $0.userID == userID }) else {
            print("Record with userID \(userID) already exists.")
            return
        }
        let newRecord = Record(name: name, userID: userID)
        records.append(newRecord)
        saveRecords()
    }

    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
        saveRecords()
    }
}

import SwiftUI

struct RecordsView: View {
    @StateObject private var viewModel = RecordsViewModel()
    @State private var newName = ""
    @State private var newUserID = ""

    var body: some View {
        VStack {
            TextField("Name", text: $newName)
            TextField("UserID", text: $newUserID)
            NavigationView {
                List {
                    ForEach(viewModel.records) { record in
                        Text("\(record.name) (\(record.userID))")
                    }
                    .onDelete(perform: viewModel.deleteRecord)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            viewModel.appendRecord(name: newName, userID: newUserID)
                        }
                    }
                }
                .navigationTitle("Records")
            }
        }
        .padding(10)
        .onAppear {
            viewModel.loadRecords()
        }
    }
}
