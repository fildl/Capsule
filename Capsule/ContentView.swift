//
//  ContentView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ClothingItem]

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item Details: \(item.subCategory)")
                    } label: {
                        Text(item.subCategory.isEmpty ? item.mainCategory.rawValue : item.subCategory)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ClothingItem(
                mainCategory: .top,
                subCategory: "New Item",
                colors: ["#000000"]
            )
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
