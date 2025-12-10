//
//  OutfitBuilderView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
//

import SwiftUI
import SwiftData

struct OutfitBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var allItems: [ClothingItem]
    
    var outfitToEdit: Outfit?
    
    // Canvas State
    @State private var placedItems: [PlacedItem] = []
    @State private var selectedPlacedItemId: UUID? = nil
    
    // UI State
    @State private var selectedCategoryFilter: MainCategory? = nil
    @State private var isShowingSaveSheet = false
    @State private var notes: String = ""
    @State private var selectedSeasons: Set<Season> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Canvas Area (Top)
                GeometryReader { geometry in
                    ZStack {
                        Color(.systemGray6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                selectedPlacedItemId = nil
                            }
                        
                        // The Canvas Content
                        if placedItems.isEmpty {
                            ContentUnavailableView(
                                "Start Building",
                                systemImage: "tshirt",
                                description: Text("Tap items below to add them to your canvas")
                            )
                            .allowsHitTesting(false) // Let tap go through to BG
                        } else {
                            ForEach(placedItems) { placedItem in
                                CanvasItemView(
                                    placedItem: placedItem,
                                    isSelected: selectedPlacedItemId == placedItem.id,
                                    onSelect: { selectedPlacedItemId = placedItem.id },
                                    onUpdate: { updatedItem in
                                        if let index = placedItems.firstIndex(where: { $0.id == updatedItem.id }) {
                                            placedItems[index] = updatedItem
                                        }
                                    },
                                    onRemove: {
                                        placedItems.removeAll(where: { $0.id == placedItem.id })
                                        selectedPlacedItemId = nil
                                    }
                                )
                            }
                        }
                    }
                    .clipped()
                }
                .frame(maxHeight: .infinity)
                .zIndex(1)
                
                Divider()
                
                // Item Picker (Bottom)
                VStack(spacing: 0) {
                    // Category Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            SelectionFilterChip(title: "All", isSelected: selectedCategoryFilter == nil) {
                                selectedCategoryFilter = nil
                            }
                            
                            ForEach(MainCategory.allCases) { category in
                                SelectionFilterChip(title: category.rawValue, isSelected: selectedCategoryFilter == category) {
                                    selectedCategoryFilter = category
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    
                    // Filtered Items Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                            ForEach(filteredItems) { item in
                                Button {
                                    addItemToCanvas(item)
                                } label: {
                                    ItemThumbnail(item: item)
                                        .opacity(isItemPlaced(item) ? 0.5 : 1.0)
                                }
                                .disabled(isItemPlaced(item))
                            }
                        }
                        .padding()
                    }
                    .frame(height: 220)
                    .background(Color(.systemBackground))
                }
                .zIndex(0)
            }
            .navigationTitle(outfitToEdit == nil ? "New Outfit" : "Edit Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        isShowingSaveSheet = true
                    }
                    .disabled(placedItems.isEmpty)
                }
            }
            .sheet(isPresented: $isShowingSaveSheet) {
                SaveOutfitSheet(
                    placedItems: placedItems,
                    notes: $notes,
                    selectedSeasons: $selectedSeasons,
                    onSave: saveOutfit
                )
            }
            .onAppear {
                if let outfit = outfitToEdit, placedItems.isEmpty {
                    loadOutfitData(outfit)
                }
            }
        }
    }
    
    private var filteredItems: [ClothingItem] {
        if let category = selectedCategoryFilter {
            return allItems.filter { $0.mainCategory == category }
        }
        return allItems
    }
    
    private func isItemPlaced(_ item: ClothingItem) -> Bool {
        placedItems.contains(where: { $0.item.id == item.id })
    }
    
    private func addItemToCanvas(_ item: ClothingItem) {
        // Add to center with slight random offset
        let offset = CGSize(
            width: CGFloat.random(in: -20...20),
            height: CGFloat.random(in: -20...20)
        )
        let newItem = PlacedItem(item: item, offset: offset)
        placedItems.append(newItem)
        selectedPlacedItemId = newItem.id
    }
    
    private func loadOutfitData(_ outfit: Outfit) {
        notes = outfit.notes ?? ""
        selectedSeasons = outfit.seasons
        
        // Restore Layout
        if let layoutData = outfit.layoutData,
           let layoutItems = try? JSONDecoder().decode([OutfitLayoutItem].self, from: layoutData) {
            
            // Map saved layout back to PlacedItems by matching with allItems
            // We use allItems query to ensure we have the live SwiftData objects
            var newPlacedItems: [PlacedItem] = []
            
            for layoutItem in layoutItems {
                if let clothingItem = allItems.first(where: { $0.id == layoutItem.itemId }) {
                    let placed = PlacedItem(
                        item: clothingItem,
                        offset: CGSize(width: layoutItem.x, height: layoutItem.y),
                        scale: layoutItem.scale,
                        rotation: Angle(degrees: layoutItem.rotationDegrees)
                    )
                    newPlacedItems.append(placed)
                }
            }
            placedItems = newPlacedItems
            
        } else if let items = outfit.items {
            // Fallback for outfits without layout data
            // Just place them in a default arrangement
            placedItems = items.map { item in
                PlacedItem(
                    item: item,
                    offset: CGSize(width: CGFloat.random(in: -30...30), height: CGFloat.random(in: -30...30))
                )
            }
        }
    }
    
    @MainActor
    private func saveOutfit() {
        // Generate Snapshot
        let renderer = ImageRenderer(content:
            ZStack {
                Color.white // White background
                ForEach(placedItems) { placedItem in
                    if let data = placedItem.item.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .scaleEffect(placedItem.scale)
                            .rotationEffect(placedItem.rotation)
                            .offset(placedItem.offset)
                    }
                }
            }
            .frame(width: 400, height: 400)
        )
        
        let canvasData = renderer.uiImage?.pngData()
        let items = placedItems.map { $0.item }
        
        // Serialize Layout
        let layoutItems = placedItems.map { placed in
            OutfitLayoutItem(
                itemId: placed.item.id,
                x: placed.offset.width,
                y: placed.offset.height,
                scale: placed.scale,
                rotationDegrees: placed.rotation.degrees,
                zIndex: 0 // Not fully using z-index logic yet other than array order
            )
        }
        let layoutData = try? JSONEncoder().encode(layoutItems)
        
        if let outfit = outfitToEdit {
            // Update Existing
            outfit.items = items
            outfit.seasons = selectedSeasons
            outfit.notes = notes.isEmpty ? nil : notes
            outfit.canvasImageData = canvasData
            outfit.layoutData = layoutData
        } else {
            // Create New
            let outfit = Outfit(
                items: items,
                seasons: selectedSeasons,
                notes: notes.isEmpty ? nil : notes,
                canvasImageData: canvasData,
                layoutData: layoutData
            )
            modelContext.insert(outfit)
        }
        
        dismiss()
    }
}

// MARK: - Helper Types

struct PlacedItem: Identifiable {
    let id = UUID()
    let item: ClothingItem
    var offset: CGSize
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}

struct CanvasItemView: View {
    let placedItem: PlacedItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onUpdate: (PlacedItem) -> Void
    let onRemove: () -> Void
    
    // Gesture States
    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    
    var body: some View {
        if let data = placedItem.item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 150) // Base Size
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
                )
                .scaleEffect(placedItem.scale * currentScale)
                .rotationEffect(placedItem.rotation + currentRotation)
                .offset(x: placedItem.offset.width + dragOffset.width,
                        y: placedItem.offset.height + dragOffset.height)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            onSelect()
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            onSelect() // Select on drag start
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            var newItem = placedItem
                            newItem.offset.width += value.translation.width
                            newItem.offset.height += value.translation.height
                            onUpdate(newItem)
                            dragOffset = .zero
                        }
                )
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            currentScale = value
                        }
                        .onEnded { value in
                            var newItem = placedItem
                            newItem.scale *= value
                            onUpdate(newItem)
                            currentScale = 1.0
                        }
                )
                .zIndex(isSelected ? 2 : 1) // Bring selected to front
                .overlay(alignment: .topTrailing) {
                    // Show delete button only if selected
                    if isSelected {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: placedItem.offset.width + 10, y: placedItem.offset.height - 10)
                        // Note: Delete button offset tracking is complex with transforms. 
                        // Simplified: put it in ZStack but it rotates with image.
                        // Actually better to handle delete differently or accept it rotates.
                    }
                }
        }
    }
}

struct SaveOutfitSheet: View {
    let placedItems: [PlacedItem]
    @Binding var notes: String
    @Binding var selectedSeasons: Set<Season>
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(placedItems.count) Items")
                                .font(.headline)
                            HStack(spacing: -10) {
                                ForEach(placedItems.prefix(5)) { placed in
                                    if let data = placed.item.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(.white, lineWidth: 2))
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Seasons") {
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
                        onSave()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// Helper Views
struct SelectionFilterChip: View {
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
