//
//  ArchivedItemsView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
//

import SwiftUI
import SwiftData

struct ArchivedItemsView: View {
    @State private var selectedSegment = 0
    
    var body: some View {
        VStack {
            Picker("View Mode", selection: $selectedSegment) {
                Text("Items").tag(0)
                Text("Outfits").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if selectedSegment == 0 {
                // Show archived items
                ItemGridView(
                    sort: [SortDescriptor(\.createdAt, order: .reverse)],
                    predicate: #Predicate<ClothingItem> { $0.isArchived }
                )
            } else {
                // Show archived outfits
                OutfitGridView(
                    sort: [SortDescriptor(\.createdAt, order: .reverse)],
                    predicate: #Predicate<Outfit> { $0.isArchived }
                )
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ArchivedItemsView()
            .modelContainer(for: [ClothingItem.self, Outfit.self], inMemory: true)
    }
}
