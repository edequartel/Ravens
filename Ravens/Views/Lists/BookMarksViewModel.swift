//
//  BookMarksViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/05/2024.
//

import Foundation
import SwiftyBeaver


struct BookMark: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
//    var name: String?
//    var group: String?
    var speciesID: Int //bookmarkID
}


import SwiftUI


class BookMarksViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var records: [BookMark] = []
    let filePath: URL
    
    init() {
        log.error("init BookMarksViewModel")
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("bookmarks.json")
        
        loadRecords()
    }
    
    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([BookMark].self, from: data)
            log.error("Loadeds \(records.count) bookmarks")
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
    
    func isSpeciesIDInRecords(speciesID: Int) -> Bool {
        return records.contains(where: { $0.speciesID == speciesID })
    }
    
    func appendRecord(speciesID: Int) {
        guard !records.contains(where: { $0.speciesID == speciesID }) else {
            print("Record with userID \(speciesID) already exists.")
            return
        }
        let newRecord = BookMark(speciesID: speciesID)
        records.append(newRecord)
        saveRecords()
    }
    
    
    func removeRecord(speciesID: Int) {
        print("removeRecord \(speciesID)")
        if let index = records.firstIndex(where: { $0.speciesID == speciesID }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with speciesID \(speciesID) does not exist.")
        }
    }
}

import SwiftUI

struct BookMarksView: View {
    @EnvironmentObject private var viewModel: BookMarksViewModel
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
                            Text("(\(record.speciesID))")
                            Spacer()
                        }
                    }
//                    .onDelete(perform: viewModel.deleteRecord)
                    
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
//        .onAppear {
//            viewModel.loadRecords()
//        }
    }
}
