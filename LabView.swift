//
//  LabView.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/02/2024.
//

import SwiftUI

struct ContentView: View {
    struct Fruit: Identifiable, Equatable {
        let id = UUID()
        let name: String
    }

    let fruits = [
        Fruit(name: "Apple"),
        Fruit(name: "Banana"),
        Fruit(name: "Cherry"),
        Fruit(name: "Orange"),
        Fruit(name: "Grapes"),
        Fruit(name: "Kiwi"),
        Fruit(name: "Mango"),
        Fruit(name: "Peach"),
        Fruit(name: "Pear"),
        Fruit(name: "Strawberry")
    ]

    @State private var selectedFruit: Fruit?
    @State private var selectedFruixt: Fruit?

    var body: some View {
        NavigationView {
            List(fruits) { fruit in
                HStack {
                    Button("xxx") {
                        print("xxx")
                    }
                    FruitRow(fruit: fruit, isSelected: fruit == selectedFruixt, selectedFruit: $selectedFruit)
                }
            }
            .navigationTitle("Fruit List")

            .sheet(item: $selectedFruit) { selectedFruit in
                FruitDetailView(fruit: selectedFruit)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FruitRow: View {
    let fruit: ContentView.Fruit
    let isSelected: Bool
    @Binding var selectedFruit: ContentView.Fruit?

    var body: some View {
        HStack {
            Button {
                selectedFruit = fruit
            } label: {
                HStack {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(isSelected ? .green : .gray)
                    Text(fruit.name)
                }
            }
        }
    }
}

struct FruitDetailView: View {
    let fruit: ContentView.Fruit

    var body: some View {
        VStack {
            Text("Details for \(fruit.name)")
                .font(.title)
                .padding()

            // Additional details or content for the selected fruit can be added here
        }
        .navigationBarTitle(fruit.name, displayMode: .inline)
    }
}




#Preview {
    ContentView()
}

