//
//  SwiftDataExample.swift
//  Ravens
//
//  Created by Eric de Quartel on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class Favoriet {
  var title: String
  var isCompleted: Bool
  var obsid: Int

  init(title: String, isCompleted: Bool = false, obsid: Int) {
    self.title = title
    self.isCompleted = isCompleted
    self.obsid = obsid
  }
}

struct FavoritesListView: View {
  @Environment(\.modelContext) private var context
  @Query private var favorites: [Favoriet]

  @State private var newFavoriteTitle: String = ""

  var body: some View {
    NavigationView {
      VStack {
        HStack {
          TextField("Nieuwe favoriet...", text: $newFavoriteTitle)
            .textFieldStyle(.roundedBorder)

          Button(action: addFavorite) {
            Image(systemName: "plus")
              .padding(8)
          }
          .disabled(newFavoriteTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()

        List {
          ForEach(favorites) { favorite in
            HStack {
              Text(favorite.title)
              Spacer()
              if favorite.isCompleted {
                Image(systemName: "checkmark.circle")
              }
            }
          }
          .onDelete(perform: deleteFavorites)
        }
        .listStyle(.insetGrouped)
      }
      .navigationTitle("Favorieten")
    }
  }

  private func addFavorite() {
      let trimmedTitle = newFavoriteTitle.trimmingCharacters(in: .whitespaces)
      guard !trimmedTitle.isEmpty else { return }

      let favorite = Favoriet(title: trimmedTitle, obsid: 100)
      context.insert(favorite)

      do {
          try context.save() // <-- SAVE the context after insert
      } catch {
          print("Failed to save context:", error.localizedDescription)
      }

      newFavoriteTitle = ""
  }
//  private func addFavorite() {
//    let trimmedTitle = newFavoriteTitle.trimmingCharacters(in: .whitespaces)
//    guard !trimmedTitle.isEmpty else { return }
//
//    let favorite = Favoriet(title: trimmedTitle, obsid: 100)
//    context.insert(favorite)
//
//    newFavoriteTitle = ""
//  }

//  private func deleteFavorites(at offsets: IndexSet) {
//    for index in offsets {
//      let favorite = favorites[index]
//      context.delete(favorite)
//    }
//  }

  private func deleteFavorites(at offsets: IndexSet) {
      for index in offsets {
          let favorite = favorites[index]
          context.delete(favorite)
      }

      do {
          try context.save() // <-- Save after deletion too
      } catch {
          print("Failed to save after delete:", error.localizedDescription)
      }
  }
}
