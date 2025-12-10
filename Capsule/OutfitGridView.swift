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
    
    init(sort: [SortDescriptor<Outfit>], predicate: Predicate<Outfit>?) {
        _outfits = Query(filter: predicate, sort: sort)
    }
    
    var body: some View {
        Group {
            if outfits.isEmpty {
                ContentUnavailableView(
                    "No Outfits Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters or add a new outfit")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(outfits) { outfit in
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
