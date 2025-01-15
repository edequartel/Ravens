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

  @EnvironmentObject var userViewModel:  UserViewModel
  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @EnvironmentObject var settings: Settings

  @State private var navigateToObservers = false
  var body: some View {
    VStack(alignment: .leading) {
      //          Text("Token: \(keyChainviewModel.token)")
      //          Text("\(userViewModel.user?.id ?? 0)")
      //            .font(.caption)
      if (!keyChainviewModel.token.count.words.isEmpty) {
        HStack {
          Spacer()
          Text("\(userViewModel.user?.id ?? 0)")
          Text("\(userViewModel.user?.name ?? "unknown")")
          Spacer()
        }
        .bold()

        HStack {
          Spacer()
          QRCodeView(input: "ravens://"+String(userViewModel.user?.name ?? "unknown")+"/"+String(userViewModel.user?.id ?? 0))
            .frame(width: 100, height: 100)
            .padding(10)
          Spacer()
        }
      }
    }
  }
}

#Preview {
  UserView()
    .environmentObject(KeychainViewModel())
    .environmentObject(UserViewModel())
    .environmentObject(Settings())

}
