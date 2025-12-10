//
//  WardrobeView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Query private var allItems: [ClothingItem] // For metadata extraction for filters
    
    @State private var selectedSegment = 0
    @State private var isShowingAddItem = false
    @State private var isShowingOutfitBuilder = false
    @State private var isShowingSettings = false
    @State private var isShowingSortFilter = false
    
    // Sort & Filter State
    @State private var sortOption: SortOption = .dateCreatedDesc
    @State private var filterCriteria = FilterCriteria()
    
    var availableBrands: [String] {
        let userBrands = allItems.compactMap { $0.brand }.filter { !$0.isEmpty }
        return Array(Set(userBrands)).sorted()
    }
    
    var availableColors: [ClothingColor] {
        let userColors = Set(allItems.flatMap { $0.colors })
        // Filter ClothingColor enum cases that are present in user data
        // Or if user wants ALL options, we can just show all.
        // Dynamic filter usually implies "show what I have".
        // Let's show all for now to allow filtering for things you MIGHT add? No, usually "Filter by Red" implies find red things.
        // Let's filter ClothingColor.allCases where rawValue is in userKey.
        // BUT, items store colors as Strings.
        return ClothingColor.allCases.filter { userColors.contains($0.rawValue) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("View Mode", selection: $selectedSegment) {
                    Text("Items").tag(0)
                    Text("Outfits").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedSegment) { _, newValue in
                    if newValue == 1 && !SortOption.outfitOptions.contains(sortOption) {
                        sortOption = .dateCreatedDesc
                    }
                }
                
                // Sort & Filter Controls
                HStack(spacing: 12) {
                    // Sort Menu
                    Menu {
                        ForEach(selectedSegment == 1 ? SortOption.outfitOptions : SortOption.allCases) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort")
                            Spacer()
                            Text(sortOption.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Filter Button
                    Button {
                        isShowingSortFilter = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .symbolVariant(filterCriteria.hasActiveFilters ? .fill : .none)
                            Text("Filter")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(filterCriteria.hasActiveFilters ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(filterCriteria.hasActiveFilters ? Color.blue : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(filterCriteria.hasActiveFilters ? .blue : .primary)
                }
                .padding(.horizontal)
                
                if selectedSegment == 0 {
                    ItemGridView(
                        sort: sortOption.itemSortDescriptors,
                        predicate: filterCriteria.itemPredicate
                    )
                } else {
                    OutfitGridView(
                        sort: sortOption.outfitSortDescriptors,
                        predicate: filterCriteria.outfitPredicate
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        if selectedSegment == 0 {
                            isShowingAddItem = true
                        } else {
                            isShowingOutfitBuilder = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $isShowingOutfitBuilder) {
                OutfitBuilderView()
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $isShowingSortFilter) {
                FilterSheet(
                    filterCriteria: $filterCriteria,
                    availableBrands: availableBrands,
                    availableColors: availableColors
                )
            }
            .padding(.bottom, 8) 
        }
    }
}

// MARK: - Sort & Filter Models

enum SortOption: String, CaseIterable, Identifiable {
    case dateCreatedDesc = "Newest First"
    case dateCreatedAsc = "Oldest First"
    case purchaseDateDesc = "Purchase Date (Newest)"
    case purchaseDateAsc = "Purchase Date (Oldest)"
    case priceHigh = "Price (High to Low)"
    case priceLow = "Price (Low to High)"
    
    var id: String { rawValue }
    
    static let outfitOptions: [SortOption] = [.dateCreatedDesc, .dateCreatedAsc]
    
    var itemSortDescriptors: [SortDescriptor<ClothingItem>] {
        switch self {
        case .dateCreatedDesc: return [SortDescriptor(\.createdAt, order: .reverse)]
        case .dateCreatedAsc: return [SortDescriptor(\.createdAt, order: .forward)]
        case .purchaseDateDesc: return [SortDescriptor(\.purchaseDate, order: .reverse)]
        case .purchaseDateAsc: return [SortDescriptor(\.purchaseDate, order: .forward)]
        case .priceHigh: return [SortDescriptor(\.price, order: .reverse)]
        case .priceLow: return [SortDescriptor(\.price, order: .forward)]
        }
    }
    
    var outfitSortDescriptors: [SortDescriptor<Outfit>] {
        switch self {
        case .dateCreatedDesc: return [SortDescriptor(\.createdAt, order: .reverse)]
        case .dateCreatedAsc: return [SortDescriptor(\.createdAt, order: .forward)]
        default: return [SortDescriptor(\.createdAt, order: .reverse)]
        }
    }
}

struct FilterCriteria {
    var selectedCategory: MainCategory? = nil
    var selectedBrand: String? = nil
    var selectedSeason: Season? = nil
    var selectedColor: ClothingColor? = nil
    
    var hasActiveFilters: Bool {
        selectedCategory != nil || selectedBrand != nil || selectedSeason != nil || selectedColor != nil
    }
    
    var itemPredicate: Predicate<ClothingItem> {
        let catRaw = selectedCategory?.rawValue
        let brandName = selectedBrand
        let seasonRaw = selectedSeason?.rawValue
        let colorRaw = selectedColor?.rawValue
        
        let filterCat = catRaw != nil
        let targetCat = catRaw ?? ""
        
        let filterBrand = brandName != nil
        let targetBrand = brandName ?? ""
        
        let filterSeason = seasonRaw != nil
        let targetSeason = seasonRaw ?? ""
        
        let filterColor = colorRaw != nil
        let targetColor = colorRaw ?? ""
        
        return #Predicate<ClothingItem> { item in
            !item.isArchived &&
            (!filterCat || item.mainCategoryRaw == targetCat) &&
            (!filterBrand || item.brand == targetBrand) &&
            (!filterSeason || item.seasonsRaw.contains(targetSeason)) &&
            (!filterColor || item.colors.contains(targetColor))
        }
    }
    
    var outfitPredicate: Predicate<Outfit> {
        let seasonRaw = selectedSeason?.rawValue
        let filterSeason = seasonRaw != nil
        let targetSeason = seasonRaw ?? ""
        
        return #Predicate<Outfit> { outfit in
            !outfit.isArchived &&
            (!filterSeason || outfit.seasonsRaw.contains(targetSeason))
        }
    }
}

struct FilterSheet: View {
    @Binding var filterCriteria: FilterCriteria
    var availableBrands: [String]
    var availableColors: [ClothingColor]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Filter Items") {
                     Picker("Category", selection: Binding(
                        get: { filterCriteria.selectedCategory },
                        set: { filterCriteria.selectedCategory = $0 }
                     )) {
                        Text("All Categories").tag(MainCategory?.none)
                        ForEach(MainCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat as MainCategory?)
                        }
                     }
                    
                    Picker("Brand", selection: Binding(
                       get: { filterCriteria.selectedBrand },
                       set: { filterCriteria.selectedBrand = $0 }
                    )) {
                       Text("All Brands").tag(String?.none)
                       ForEach(availableBrands, id: \.self) { brand in
                           Text(brand).tag(brand as String?)
                       }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Season", selection: Binding(
                        get: { filterCriteria.selectedSeason },
                        set: { filterCriteria.selectedSeason = $0 }
                    )) {
                        Text("All Seasons").tag(Season?.none)
                        ForEach(Season.allCases) { season in
                            Text(season.rawValue).tag(season as Season?)
                        }
                    }
                    
                    // Colors
                    VStack(alignment: .leading) {
                        Text("Color")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(availableColors) { color in
                                    ZStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 32, height: 32)
                                            .overlay(Circle().stroke(Color.gray.opacity(0.2)))
                                        
                                        if filterCriteria.selectedColor == color {
                                            Image(systemName: "checkmark")
                                                .font(.caption)
                                                .foregroundStyle(.white) // or contrasting
                                        }
                                    }
                                    .onTapGesture {
                                        if filterCriteria.selectedColor == color {
                                            filterCriteria.selectedColor = nil
                                        } else {
                                            filterCriteria.selectedColor = color
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if filterCriteria.hasActiveFilters {
                    Section {
                        Button("Clear Filters") {
                            filterCriteria.selectedCategory = nil
                            filterCriteria.selectedBrand = nil
                            filterCriteria.selectedSeason = nil
                            filterCriteria.selectedColor = nil
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    WardrobeView()
}
