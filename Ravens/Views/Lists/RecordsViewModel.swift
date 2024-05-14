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


import SwiftUI

class URLHandler: ObservableObject {
    @Published var urlString: String = ""
}

class ObserversViewModel: ObservableObject {
    @Published var records: [Observer] = []
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
    
    func appendRecord(name: String, userID: Int) {
        guard !records.contains(where: { $0.userID == userID }) else {
            print("Record with userID \(userID) already exists.")
            return
        }
        let newRecord = Observer(name: name, userID: userID)
        records.append(newRecord)
        saveRecords()
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
        saveRecords()
    }
}

import SwiftUI

struct ObserversView: View {
    @EnvironmentObject private var viewModel: ObserversViewModel
    @State private var newName = ""
    @State private var newUserID = 0
    
    var body: some View {
        //        VStack {
        //            TextField("Name", text: $newName)
        //            TextField("UserID", text: $newUserID)
//        NavigationView {
            VStack {
                UserView()
                
                List {
                    ForEach(viewModel.records) { record in
                        HStack{
                            Text("\(record.name) (\(record.userID))")
                            Spacer()
                        }
                    }
                    .onDelete(perform: viewModel.deleteRecord)
                }
            }
            //                .toolbar {
            //                    ToolbarItem(placement: .navigationBarTrailing) {
            //                        Button("Add") {
            //                            viewModel.appendRecord(name: newName, userID: newUserID)
            //                        }
            //                    }
            //                }
            //                .navigationTitle("Observers")
//        }
        //        }
        //        .padding(10)
        .onAppear {
            viewModel.loadRecords()
        }
    }
}
