//
//  ringtone.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/07/2025.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

//extension UTType {
//    static var mpeg3: UTType {
//        UTType(importedAs: "audio/mpeg")
//    }
//}

struct RingtoneMakerView: View {
  @State private var mp3URL: URL?
  @State private var startTime: Double = 0
  @State private var duration: Double = 30
  @State private var isExporting = false
  @State private var exportMessage = ""
  @State private var showingImporter = false
  @State private var lastExportedURL: URL?
  
  var body: some View {
    VStack(spacing: 20) {
      Text("🎵 MP3 ➜ M4R Ringtone")
        .font(.title2.bold())
      
      Button("📂 Import MP3") {
        showingImporter = true
      }
      
      if let mp3URL {
        Text(mp3URL.lastPathComponent)
          .font(.caption)
          .foregroundColor(.secondary)
        
        HStack {
          Text("Start:")
          Slider(value: $startTime, in: 0...120, step: 1)
          Text("\(Int(startTime))s")
        }
        
        HStack {
          Text("Duration:")
          Slider(value: $duration, in: 1...40, step: 1)
          Text("\(Int(duration))s")
        }
        
        Button("🎬 Convert to M4R") {
          exportRingtone()
        }
        .disabled(isExporting)
        
        Button("🔊 Share / Use as Ringtone") {
          if let url = lastExportedURL {
            share(url: url)
          }
        }
        .disabled(lastExportedURL == nil || isExporting)
      }
      
      if isExporting {
        ProgressView()
      }
      
      Text(exportMessage)
        .font(.footnote)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.top, 10)
    }
    .padding()
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
      case .failure(let error):
        self.exportMessage = "Import error: \(error.localizedDescription)"
      }
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
    exportMessage = "Exporting..."
    
    let asset = AVURLAsset(url: mp3URL)
    let tempDir = FileManager.default.temporaryDirectory
    let m4aURL = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
    
    guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
      isExporting = false
      exportMessage = "Unable to create exporter."
      return
    }
    
    exporter.outputURL = m4aURL
    exporter.outputFileType = .m4a
    exporter.timeRange = CMTimeRange(
      start: CMTime(seconds: startTime, preferredTimescale: 600),
      duration: CMTime(seconds: duration, preferredTimescale: 600)
    )
    
    exporter.exportAsynchronously {
      DispatchQueue.main.async {
        self.isExporting = false
        if exporter.status == .completed {
          do {
            let m4rURL = m4aURL.deletingPathExtension().appendingPathExtension("m4r")
            try FileManager.default.moveItem(at: m4aURL, to: m4rURL)
            self.lastExportedURL = m4rURL
            self.exportMessage = """
                      ✅ Exported! Tap ‘Share / Use as Ringtone’.
                      
                      Tip: If no ringtone option appears, save to Files,
                      then long-press it → Use Sound As...
                      """
          } catch {
            self.exportMessage = "Rename error: \(error.localizedDescription)"
          }
        } else {
          self.exportMessage = "Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")"
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
