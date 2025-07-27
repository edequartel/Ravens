//
//  Untitled.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/07/2025.
//

// ContentView.swift

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PdfView: View {
    @State private var showFolderPicker = false
    @State private var pdfData: Data?

    var body: some View {
        VStack(spacing: 20) {
            Text("Export PDF to Folder")
                .font(.title)

            Button("Generate PDF") {
                pdfData = generatePDF(from: "Welcome Eric")
                showFolderPicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .fileExporter(
            isPresented: $showFolderPicker,
            document: PDFExportFile(data: pdfData ?? Data()),
            contentType: .pdf,
            defaultFilename: "WelcomeEric"
        ) { result in
            switch result {
            case .success(let url):
                print("📄 PDF saved to: \(url)")
            case .failure(let error):
                print("❌ Failed to save PDF: \(error)")
            }
        }
    }

    func generatePDF(from text: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyApp",
            kCGPDFContextAuthor: "You"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24)
            ]
            let textRect = CGRect(x: 72, y: 72, width: pageRect.width - 144, height: pageRect.height - 144)
            text.draw(in: textRect, withAttributes: attributes)
        }

        return data
    }
}

/// Wrapper for exporting PDF
struct PDFExportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
