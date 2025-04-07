//
//  DownloadFile.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/04/2025.
//

import SwiftUI
import Alamofire
import UIKit

class FileDownloader: ObservableObject {

    // MARK: - Public download method
    func downloadFile(
        from urlString: String,
        fileName: String,
        fileExtension: String = "mp3",
        completion: @escaping (URL?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil)
            return
        }

        let ravensFolder = getRavensFolder()
        let fileURL = ravensFolder.appendingPathComponent("\(fileName).\(fileExtension)")

        let destination: DownloadRequest.Destination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(url, to: destination).response { response in
            if let error = response.error {
                print("Download error: \(error)")
                completion(nil)
            } else if let filePath = response.fileURL {
                print("File downloaded to: \(filePath)")
                completion(filePath)
            }
        }
    }

    // MARK: - Helper: Get or create Ravens folder in Documents
    private func getRavensFolder() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let ravensFolder = documents.appendingPathComponent("Audio")

        if !FileManager.default.fileExists(atPath: ravensFolder.path) {
            try? FileManager.default.createDirectory(at: ravensFolder, withIntermediateDirectories: true, attributes: nil)
        }

        return ravensFolder
    }
}
