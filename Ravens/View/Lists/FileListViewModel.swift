//
//  FileListViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/05/2024.
//

import Foundation
import SwiftUI

// ViewModel to handle fetching files from the Documents directory recursively
class FileListViewModel: ObservableObject {
    @Published var files: [String] = []
    
    init() {
        listDocumentsDirectory()
    }
    
    func listDocumentsDirectory() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        // Recursive function to traverse directories
        func listFiles(at path: URL) {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                for fileURL in fileURLs {
                    if fileManager.isDirectory(url: fileURL) {
                        // If the item is a directory, recursively list its contents
                        listFiles(at: fileURL)
                    } else {
                        // If the item is a file, add it to the files array
                        files.append(fileURL.path.replacingOccurrences(of: documentsPath.path, with: ""))
                    }
                }
            } catch {
                print("Error while enumerating files \(path.path): \(error.localizedDescription)")
            }
        }
        
        // Start listing files from the root Documents directory
        listFiles(at: documentsPath)
    }
}

extension FileManager {
    // Helper function to check if a URL is a directory
    func isDirectory(url: URL) -> Bool {
        var isDir: ObjCBool = false
        _ = self.fileExists(atPath: url.path, isDirectory: &isDir)
        return isDir.boolValue
    }
}

// SwiftUI view that uses the ViewModel
struct FileListView: View {
    @ObservedObject var viewModel = FileListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.files, id: \.self) { file in
                Text(file)
            }
            .navigationTitle("Files")
        }
    }
}

//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            FileListView()
//        }
//    }
//}
