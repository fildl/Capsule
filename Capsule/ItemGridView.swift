//
//  ItemGridView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI
import SwiftData

struct ItemGridView: View {
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var items: [ClothingItem]
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
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
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        ItemCard(item: item)
                    }
                }
                .padding()
            }
        }
    }
}

struct ItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            GeometryReader { geometry in
                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipped()
            
            // Info Area
            VStack(alignment: .leading, spacing: 4) {
                Text(item.subCategory.isEmpty ? item.mainCategory.rawValue : item.subCategory)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let brand = item.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ItemGridView()
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
