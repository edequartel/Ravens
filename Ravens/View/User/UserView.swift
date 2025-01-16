//
//  UserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver

struct UserView: View {
    let log = SwiftyBeaver.self

    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        VStack {
            Text("\(userViewModel.user?.name ?? "unknown")")// - \(userViewModel.user?.id ?? 0)")
                .bold()

            QRCodeView(
                input: "ravens://\(userViewModel.user?.name ?? "unknown")/\(userViewModel.user?.id ?? 0)"
            )
            .frame(width: 150, height: 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
    }
}

#Preview {
  UserView()
    .environmentObject(UserViewModel())
}
