//
//  OutfitDetailView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
//

import SwiftUI
import SwiftData

struct OutfitDetailView: View {
    @Bindable var outfit: Outfit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hero Image (Canvas)
                Group {
                    if let data = outfit.canvasImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        // Fallback Grid
                        let previewItems = Array(outfit.items?.prefix(4) ?? [])
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                            ForEach(previewItems) { item in
                                if let data = item.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                } else {
                                    Color.gray.opacity(0.2)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal)
                
                // Items Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("ITEMS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    if let items = outfit.items, !items.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(items) { item in
                                    NavigationLink(destination: ItemDetailView(item: item)) {
                                        VStack {
                                            if let data = item.imageData, let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .background(Color(.systemGray6))
                                                    .cornerRadius(8)
                                            }
                                            Text(item.brand ?? item.mainCategory.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                                .frame(width: 80)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No items linked")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    // Seasons
                    if !outfit.seasons.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SEASONS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(Array(outfit.seasons), id: \.self) { season in
                                    Text(season.rawValue)
                                        .font(.callout)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = outfit.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            Text(notes)
                                .font(.body)
                        }
                    }
                    
                    Text("Created on \(outfit.createdAt.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Outfit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            OutfitBuilderView(outfitToEdit: outfit)
        }
    }
}
