//
//  OutfitBuilderView.swift
//  Capsule
//
//  Created by Capsule Assistant on 06/12/25.
//

import SwiftUI
import SwiftData

struct OutfitBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var allItems: [ClothingItem]
    
    // Canvas State
    @State private var selectedItems: [ClothingItem] = []
    
    // UI State
    @State private var selectedCategoryFilter: MainCategory? = nil
    @State private var isShowingSaveSheet = false
    @State private var notes: String = ""
    @State private var selectedSeasons: Set<Season> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Canvas Area (Top)
                ZStack {
                    Color(.systemGray6)
                        .ignoresSafeArea()
                    
                    if selectedItems.isEmpty {
                        ContentUnavailableView(
                            "Start Building",
                            systemImage: "tshirt",
                            description: Text("Tap items below to add them to your outfit")
                        )
                    } else {
                        // Interactive Canvas - Simple Grid for now
                        // Future: Freeform drag & drop
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                                ForEach(selectedItems) { item in
                                    ZStack(alignment: .topTrailing) {
                                        ItemThumbnail(item: item)
                                        
                                        // Remove Button
                                        Button {
                                            selectedItems.removeAll { $0.id == item.id }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.gray)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 5, y: -5)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                Divider()
                
                // Item Picker (Bottom)
                VStack(spacing: 0) {
                    // Category Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "All", isSelected: selectedCategoryFilter == nil) {
                                selectedCategoryFilter = nil
                            }
                            
                            ForEach(MainCategory.allCases) { category in
                                FilterChip(title: category.rawValue, isSelected: selectedCategoryFilter == category) {
                                    selectedCategoryFilter = category
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    
                    // Filtered Items Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                            ForEach(filteredItems) { item in
                                Button {
                                    if !selectedItems.contains(item) {
                                        selectedItems.append(item)
                                    }
                                } label: {
                                    ItemThumbnail(item: item)
                                        .opacity(selectedItems.contains(item) ? 0.5 : 1.0)
                                }
                                .disabled(selectedItems.contains(item))
                            }
                        }
                        .padding()
                    }
                    .frame(height: 250) // Fixed height for picker
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        isShowingSaveSheet = true
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            .sheet(isPresented: $isShowingSaveSheet) {
                NavigationStack {
                    Form {
                        Section("Seasons") {
                            // Seasons Logic (Reuse logic from AddItemView roughly)
                             DisclosureGroup(content: {
                                Toggle("All Year", isOn: Binding(
                                    get: { selectedSeasons.count == Season.allCases.count },
                                    set: { isOn in
                                        if isOn { selectedSeasons = Set(Season.allCases) }
                                        else { selectedSeasons.removeAll() }
                                    }
                                ))
                                ForEach(Season.allCases) { season in
                                    Toggle(season.rawValue, isOn: Binding(
                                        get: { selectedSeasons.contains(season) },
                                        set: { isOn in
                                            if isOn { selectedSeasons.insert(season) }
                                            else { selectedSeasons.remove(season) }
                                        }
                                    ))
                                }
                            }, label: {
                                Text(selectedSeasons.isEmpty ? "Select Seasons" : selectedSeasons.map { $0.rawValue }.joined(separator: ", "))
                            })
                        }
                        
                        Section("Notes") {
                            TextField("Outfit notes...", text: $notes, axis: .vertical)
                        }
                    }
                    .navigationTitle("Save Outfit")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveOutfit()
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private var filteredItems: [ClothingItem] {
        if let category = selectedCategoryFilter {
            return allItems.filter { $0.mainCategory == category }
        }
        return allItems
    }
    
    private func saveOutfit() {
        let outfit = Outfit(items: selectedItems, seasons: selectedSeasons, notes: notes.isEmpty ? nil : notes)
        modelContext.insert(outfit)
        dismiss()
    }
}

// Helper Views
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ItemThumbnail: View {
    let item: ClothingItem
    
    var body: some View {
        Group {
            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray.opacity(0.1)
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
