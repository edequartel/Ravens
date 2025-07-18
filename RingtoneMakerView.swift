//
//  ringtone.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/07/2025.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct RingtoneMakerView: View {
  @State private var mp3URL: URL?
  @State private var startTime: Double = 0
  @State private var duration: Double = 30
  @State private var isExporting = false
  @State private var alertTitle = ""
  @State private var exportMessage = ""
  @State private var showingImporter = false
  @State private var lastExportedURL: URL?
  @State private var showAlert: Bool = false
  @State private var previousText: String = ""

  var body: some View {
    HStack {
      Button(shareAudio) {
        showingImporter = true
      }
      Spacer()

      if isExporting {
        ProgressView()
          .foregroundColor(.blue)
      }
    }

    .fileImporter(
      isPresented: $showingImporter,
      allowedContentTypes: [.mp3],
      allowsMultipleSelection: false
    ) { result in
      switch result {
      case .success(let urls):
        self.mp3URL = urls.first
        self.exportMessage = ""
        self.lastExportedURL = nil

        exportRingtone()

      case .failure(let error):
        self.exportMessage = "Import error: \(error.localizedDescription)"
      }
    }
    .onChange(of: exportMessage) {
        showAlert = true
    }

    .alert(isPresented: $showAlert) {
        Alert(
            title: Text("\(alertTitle)"),
            message: Text("\(exportMessage)"),
            dismissButton: .default(Text("OK"))
        )
    }
  }

  func exportRingtone() {
    guard let mp3URL else { return }
    guard mp3URL.startAccessingSecurityScopedResource() else {
      exportMessage = "Could not access selected file."
      return
    }
    defer { mp3URL.stopAccessingSecurityScopedResource() }

    isExporting = true
    exportMessage = ""

    let asset = AVURLAsset(url: mp3URL)
    let tempDir = FileManager.default.temporaryDirectory
    let m4aFilename = mp3URL.deletingPathExtension().lastPathComponent + ".m4a"
    let m4aURL = tempDir.appendingPathComponent(m4aFilename)

    guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
      isExporting = false
      alertTitle = "Error"
      exportMessage = "Unable to create exporter."
      return
    }

    exporter.outputURL = m4aURL
    exporter.outputFileType = .m4a
    exporter.timeRange = CMTimeRange(
      start: CMTime(seconds: startTime, preferredTimescale: 600),
      duration: CMTime(seconds: duration, preferredTimescale: 600)
    )

    print("before exporting")
    exporter.exportAsynchronously {
      DispatchQueue.main.async {
        self.isExporting = false
        if exporter.status == .completed {
          do {
            let m4rFilename = mp3URL.deletingPathExtension().lastPathComponent + ".m4r"
            let m4rURL = tempDir.appendingPathComponent(m4rFilename)

            if FileManager.default.fileExists(atPath: m4rURL.path) {
                      try FileManager.default.removeItem(at: m4rURL)
                    }

            print("\(m4rURL)")
            try FileManager.default.moveItem(at: m4aURL, to: m4rURL)

            self.lastExportedURL = m4rURL

            if let url = lastExportedURL {
              share(url: url)
            }

          } catch {
            self.alertTitle = "Error 1"
            self.exportMessage = "\(error.localizedDescription)"
          }
        } else {
          self.alertTitle = "Error 2"
          self.exportMessage = "\(exporter.error?.localizedDescription ?? "Unknown error")"
        }
      }
    }
  }

  func share(url: URL) {
    let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let root = scene.windows.first?.rootViewController {
      root.present(controller, animated: true)
    }
  }
}

#Preview {
  RingtoneMakerView()
}

//
//  ringtone.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/07/2025.
//
// import SwiftUI
// import AVFoundation
// import UniformTypeIdentifiers

// struct RingtoneMakerView: View {
//  @State private var mp3URL: URL?
//  @State private var startTime: Double = 0
//  @State private var duration: Double = 30
//  @State private var isExporting = false
//  @State private var exportMessage = ""
//  @State private var showingImporter = false
//  @State private var lastExportedURL: URL?
//
//  var body: some View {
//    VStack(spacing: 20) {
//      Text("🎵 MP3 ➜ M4R Ringtone")
//        .font(.title2.bold())
//
//      Button("📂 Import MP3") {
//        showingImporter = true
//      }
//
//      if let mp3URL {
//        Text(mp3URL.lastPathComponent)
//          .font(.caption)
//          .foregroundColor(.secondary)
//
//        HStack {
//          Text("Start:")
//          Slider(value: $startTime, in: 0...120, step: 1)
//          Text("\(Int(startTime))s")
//        }
//
//        HStack {
//          Text("Duration:")
//          Slider(value: $duration, in: 1...40, step: 1)
//          Text("\(Int(duration))s")
//        }
//
//        Button("🎬 Convert to M4R") {
//          exportRingtone()
//        }
//        .disabled(isExporting)
//
//        Button("🔊 Share / Use as Ringtone") {
//          if let url = lastExportedURL {
//            share(url: url)
//          }
//        }
//        .disabled(lastExportedURL == nil || isExporting)
//      }
//
//      if isExporting {
//        ProgressView()
//      }
//
//      Text(exportMessage)
//        .font(.footnote)
//        .foregroundColor(.gray)
//        .multilineTextAlignment(.center)
//        .padding(.top, 10)
//    }
//    .padding()
//    .fileImporter(
//      isPresented: $showingImporter,
//      allowedContentTypes: [.mp3],
//      allowsMultipleSelection: false
//    ) { result in
//      switch result {
//      case .success(let urls):
//        self.mp3URL = urls.first
//        self.exportMessage = ""
//        self.lastExportedURL = nil
//      case .failure(let error):
//        self.exportMessage = "Import error: \(error.localizedDescription)"
//      }
//    }
//  }
//
//  func exportRingtone() {
//    guard let mp3URL else { return }
//    guard mp3URL.startAccessingSecurityScopedResource() else {
//      exportMessage = "Could not access selected file."
//      return
//    }
//    defer { mp3URL.stopAccessingSecurityScopedResource() }
//
//    isExporting = true
//    exportMessage = "Exporting..."
//
//    let asset = AVURLAsset(url: mp3URL)
//    let tempDir = FileManager.default.temporaryDirectory
//    let m4aFilename = mp3URL.deletingPathExtension().lastPathComponent + ".m4a"
//    let m4aURL = tempDir.appendingPathComponent(m4aFilename)
//
//    guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
//      isExporting = false
//      exportMessage = "Unable to create exporter."
//      return
//    }
//
//    exporter.outputURL = m4aURL
//    exporter.outputFileType = .m4a
//    exporter.timeRange = CMTimeRange(
//      start: CMTime(seconds: startTime, preferredTimescale: 600),
//      duration: CMTime(seconds: duration, preferredTimescale: 600)
//    )
//
//    exporter.exportAsynchronously {
//      DispatchQueue.main.async {
//        self.isExporting = false
//        if exporter.status == .completed {
//          do {
//            let m4rFilename = mp3URL.deletingPathExtension().lastPathComponent + ".m4r"
//            let m4rURL = tempDir.appendingPathComponent(m4rFilename)
//            try FileManager.default.moveItem(at: m4aURL, to: m4rURL)
//            self.lastExportedURL = m4rURL
//            self.exportMessage = """
//                      ✅ Exported! Tap ‘Share / Use as Ringtone’.
//
//                      Tip: If no ringtone option appears, save to Files,
//                      then long-press it → Use Sound As...
//                      """
//          } catch {
//            self.exportMessage = "Rename error: \(error.localizedDescription)"
//          }
//        } else {
//          self.exportMessage = "Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")"
//        }
//      }
//    }
//  }
//
//  func share(url: URL) {
//    let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//       let root = scene.windows.first?.rootViewController {
//      root.present(controller, animated: true)
//    }
//  }
// }

// #Preview {
//  RingtoneMakerView()
// }
