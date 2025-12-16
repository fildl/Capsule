//
//  OutfitGridView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
//

import SwiftUI
import SwiftData

struct OutfitGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var outfits: [Outfit]
    
    // Action State
    @State private var outfitToDelete: Outfit?
    @State private var outfitToAssign: Outfit?
    
    // Sheet State
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingCalendarSheet = false
    
    // Calendar State
    @State private var selectedDate = Date()
    
    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]
    
    // Filters
    let filterSeason: Season?
    let filterCategory: MainCategory?
    let filterBrand: String?
    let filterColors: Set<ClothingColor>
    let filterTags: Set<Tag>
    
    init(
        sort: [SortDescriptor<Outfit>],
        predicate: Predicate<Outfit>?,
        filterSeason: Season?,
        filterCategory: MainCategory?,
        filterBrand: String?,
        filterColors: Set<ClothingColor>,
        filterTags: Set<Tag> = []
    ) {
        _outfits = Query(filter: predicate, sort: sort)
        self.filterSeason = filterSeason
        self.filterCategory = filterCategory
        self.filterBrand = filterBrand
        self.filterColors = filterColors
        self.filterTags = filterTags
    }
    
    var filteredOutfits: [Outfit] {
        if filterSeason == nil && filterCategory == nil && filterBrand == nil && filterColors.isEmpty && filterTags.isEmpty {
            return outfits
        }
        
        return outfits.filter { outfit in
            // Season Check
            if let season = filterSeason, !outfit.seasonsRaw.contains(season.rawValue) {
                return false
            }
            
            // Category Check (Contains at least one item of category)
            if let category = filterCategory {
                if !(outfit.items?.contains(where: { $0.mainCategoryRaw == category.rawValue }) ?? false) {
                    return false
                }
            }
            
            // Brand Check (Contains at least one item of brand)
            if let brand = filterBrand {
                if !(outfit.items?.contains(where: { $0.brand == brand }) ?? false) {
                    return false
                }
            }
            
            // Color Check (Palette contains ALL selected)
            if !filterColors.isEmpty {
                let outfitColors = Set((outfit.items ?? []).flatMap { $0.colors })
                let requiredColors = Set(filterColors.map { $0.rawValue })
                if !requiredColors.isSubset(of: outfitColors) {
                    return false
                }
            }
            
            // Tag Check (Must contain ALL selected)
            // Note: Currently Outfits have their OWN tags.
            // Items ALSO have tags. 
            // Logic: Does the OUTFIT have the tag? OR do ANY of the items have the tag?
            // "I tag possono anche essere usati per filtrare capi e outfit." -> Filtering outfits by tag usually means searching for "Work" outfit. 
            // But if I search "Summer" and an item is "Summer", should the outfit show?
            // User said: "I tag possono essere creati dall'utente... pool condiviso... separare o no".
            // Implementation: Filter by OUTFIT tags. If a shirt is tagged "Work", the outfit isn't necessarily "Work" unless the outfit itself is tagged.
            // However, consistent with Color/Category/Brand logic above, we usually check items.
            // But for TAGS, explicit tagging of the outfit is more powerful.
            // Let's support BOTH: Outfit Match OR Item Match?
            // "Tag shared pool". 
            // Simple approach: Match OUTFIT tags. User specifically tags outfits.
            // If I want to find outfits containing "Gucci" items (Brand), I search Brand.
            // If I want to find "Work" outfits, I verify the outfit is tagged "Work".
            
            if !filterTags.isEmpty {
                let outfitTagSet = Set(outfit.tags ?? [])
                if !filterTags.isSubset(of: outfitTagSet) {
                    return false
                }
            }
            
            return true
        }
    }
    
    var body: some View {
        Group {
            if filteredOutfits.isEmpty {
                ContentUnavailableView(
                    "No Outfits Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters or add a new outfit")
                )
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(filteredOutfits) { outfit in
                            NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                                OutfitCard(outfit: outfit)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        outfit.isArchived.toggle()
                                    }
                                } label: {
                                    Label(
                                        outfit.isArchived ? "Unarchive" : "Archive",
                                        systemImage: outfit.isArchived ? "arrow.up.bin" : "archivebox"
                                    )
                                }
                                
                                Button {
                                    outfitToAssign = outfit
                                    isShowingCalendarSheet = true
                                } label: {
                                    Label("Assign to Calendar", systemImage: "calendar")
                                }
                                
                                Button(role: .destructive) {
                                    outfitToDelete = outfit
                                    isShowingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(8)
            }
        }
        // Delete Confirmation
        .confirmationDialog(
            "Delete Outfit?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let outfit = outfitToDelete {
                    modelContext.delete(outfit)
                }
                outfitToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                outfitToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        // Calendar Sheet
        .sheet(isPresented: $isShowingCalendarSheet) {
            NavigationStack {
                Form {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                .navigationTitle("Assign to Calendar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isShowingCalendarSheet = false
                            outfitToAssign = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let outfit = outfitToAssign {
                                let log = DailyLog(date: selectedDate, outfit: outfit)
                                modelContext.insert(log)
                            }
                            isShowingCalendarSheet = false
                            outfitToAssign = nil
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct OutfitCard: View {
    let outfit: Outfit
    
    var body: some View {
        Group {
            if let canvasData = outfit.canvasImageData, let uiImage = UIImage(data: canvasData) {
                // Show Saved Collage (which is typically square)
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .background(Color.white)
            } else {
                // Fallback to Dynamic Collage
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
                            Color(.systemGray6)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    // Fill remaining spots if less than 4 items?
                    // Actually, simple grid is fine.
                }
                .background(Color.white)
            }
        }

        .aspectRatio(1, contentMode: .fit)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
