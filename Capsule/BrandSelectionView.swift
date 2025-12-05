//
//  BrandSelectionView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI
import SwiftData

struct BrandSelectionView: View {
    @Binding var selectedBrand: String
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var items: [ClothingItem]
    
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recents
    
    enum SortOption: String, CaseIterable, Identifiable {
        case recents = "Recents"
        case alphabetical = "A-Z"
        
        var id: String { rawValue }
    }
    
    var recentBrands: [String] {
        // Extract unique non-empty brands from user's items, preserving order (most recent first)
        var seen = Set<String>()
        var result: [String] = []
        for item in items {
            if let brand = item.brand, !brand.isEmpty, !seen.contains(brand) {
                seen.insert(brand)
                result.append(brand)
            }
        }
        return Array(result.prefix(10)) // Keep top 10 recents
    }
    
    var filteredBrands: [String] {
        if searchText.isEmpty {
            if sortOption == .recents {
                // Return popular brands, but put recents at the top is handled by the View structure
                // Here we just return the full list sorted A-Z for the main section
                return popularBrands
            } else {
                return popularBrands.sorted()
            }
        } else {
            return popularBrands.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            // Custom Entry if search matches nothing or user wants specific
            if !searchText.isEmpty {
                Button {
                    selectedBrand = searchText
                    dismiss()
                } label: {
                    HStack {
                        Text("Add new brand:")
                            .foregroundStyle(.secondary)
                        Text(searchText)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            // Recents Section (Only visible if default sort and no search)
            if sortOption == .recents && searchText.isEmpty && !recentBrands.isEmpty {
                Section("Recently Used") {
                    ForEach(recentBrands, id: \.self) { brand in
                        BrandRow(brand: brand, isSelected: selectedBrand == brand) {
                            selectedBrand = brand
                            dismiss()
                        }
                    }
                }
            }
            
            // All Brands
            Section(searchText.isEmpty ? "Popular Brands" : "Search Results") {
                ForEach(filteredBrands, id: \.self) { brand in
                    BrandRow(brand: brand, isSelected: selectedBrand == brand) {
                        selectedBrand = brand
                        dismiss()
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search Brand", text: $searchText)
                    .submitLabel(.done)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)
            .background(.regularMaterial)
        }
        .navigationTitle("Select Brand")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
        }
    }
}

struct BrandRow: View {
    let brand: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(brand)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrandSelectionView(selectedBrand: .constant(""))
    }
}
