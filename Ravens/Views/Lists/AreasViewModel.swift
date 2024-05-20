//
//  LocationViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 20/05/2024.
//

import Foundation


struct Area: Codable, Identifiable {
    var id: UUID = UUID()  // Unique identifier for SwiftUI List operations
    var name: String
//    var group: String?
    var areaID: Int //locatiobID
}


import SwiftUI

class AreasViewModel: ObservableObject {
    @Published var records: [Area] = []
    let filePath: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = documentsPath.appendingPathComponent("areas.json")
        
        loadRecords()
    }
    
    func loadRecords() {
        do {
            let data = try Data(contentsOf: filePath)
            records = try JSONDecoder().decode([Area].self, from: data)
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
    
    func isIDInRecords(areaID: Int) -> Bool {
        return records.contains(where: { $0.areaID == areaID })
    }
    
    func appendRecord(areaName: String, areaID: Int) {
        guard !records.contains(where: { $0.areaID == areaID }) else {
            print("Record with areaID \(areaID) already exists.")
            return
        }
        let newRecord = Area(name: areaName, areaID: areaID)
        records.append(newRecord)
        saveRecords()
    }
    
    
    func removeRecord(areaID: Int) {
        print("removeRecord \(areaID)")
        if let index = records.firstIndex(where: { $0.areaID == areaID }) {
            records.remove(at: index)
            saveRecords()
        } else {
            print("Record with areaID \(areaID) does not exist.")
        }
    }
}

import SwiftUI

struct AreasView: View {
    @EnvironmentObject private var viewModel: AreasViewModel
//    @State private var newName = ""
    @State private var newAreaID = 0
    
    var body: some View {
        //        VStack {
        //            TextField("Name", text: $newName)
        //            TextField("UserID", text: $newUserID)
//        NavigationView {
            VStack {
//                UserView()
                
                List {
                    ForEach(viewModel.records) { record in
                        HStack{
                            Text("(\(record.name))")
                            Text("\(record.areaID)")
                            Spacer()
                        }
                    }
//                    Button(action: {
////                        if viewModel.isObserverInRecords(userID: obs.user_detail?.id ?? 0) {
////                            viewModel.removeRecord(userID: obs.user_detail?.id ?? 0)
////                        } else {
//                            viewModel.appendRecord(
//                                areaID: 01245)
////                                name: obs.user_detail?.name ?? "unknown",
////                                userID: obs.user_detail?.id ?? 0)
////                        }
//                    }) {
//                        Image(systemName: "pentagon")
//                    }
//                    .tint(.red)
////                    .onDelete(perform: viewModel.deleteRecord)
                    
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
