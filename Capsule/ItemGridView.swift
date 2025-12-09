//
//  ItemGridView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI
import SwiftData

struct ItemGridView: View {
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var items: [ClothingItem]
    
    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No Items Yet",
                systemImage: "tshirt",
                description: Text("Tap + to add your first item")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            ItemCard(item: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                // Delete logic setup
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(8)
            }
        }
    }
}

struct ItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        GeometryReader { geometry in
            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipped()
            } else {
                ZStack {
                    Color(.systemGray6)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
        }

        .aspectRatio(1, contentMode: .fit)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ItemGridView()
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
