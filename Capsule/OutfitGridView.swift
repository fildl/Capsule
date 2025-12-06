//
//  OutfitGridView.swift
//  Capsule
//
//  Created by Capsule Assistant on 06/12/25.
//

import SwiftUI
import SwiftData

struct OutfitGridView: View {
    @Query(sort: \Outfit.createdAt, order: .reverse) private var outfits: [Outfit]
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        if outfits.isEmpty {
            ContentUnavailableView(
                "No Outfits Yet",
                systemImage: "square.grid.2x2",
                description: Text("Create your first outfit by tapping +")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(outfits) { outfit in
                        OutfitCard(outfit: outfit)
                    }
                }
                .padding()
            }
        }
    }
}

struct OutfitCard: View {
    let outfit: Outfit
    
    var body: some View {
        VStack(spacing: 8) {
            // Collage Preview
            // We use a simple grid of up to 4 items for preview
            let previewItems = Array(outfit.items?.prefix(4) ?? [])
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                ForEach(previewItems) { item in
                    if let data = item.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                    } else {
                        Color.gray.opacity(0.1)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .cornerRadius(12)
            .frame(height: 200) // Fixed height for card
            .clipped()
            
            // Meta Info
            if !outfit.seasons.isEmpty {
                Text(outfit.seasons.map { $0.rawValue }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            if let notes = outfit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
