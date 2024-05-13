//
//  QRImageView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var input: String

    var body: some View {
        Image(uiImage: generateQRCode(from: input))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }

    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let qrCodeImage = filter.outputImage {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    QRCodeView(input: "00.01")
}
