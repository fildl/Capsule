//
//  OutfitGridView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
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
                        NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                            OutfitCard(outfit: outfit)
                        }
                        .buttonStyle(PlainButtonStyle())
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
            // Preview Area
            Group {
                if let canvasData = outfit.canvasImageData, let uiImage = UIImage(data: canvasData) {
                    // Show Saved Collage
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.white)
                } else {
                    // Fallback to Dynamic Collage (for old outfits or failures)
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
                    .frame(height: 200)
                }
            }
            .cornerRadius(12)
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
