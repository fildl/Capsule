//
//  ItemGridView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI
import SwiftData

struct ItemGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ClothingItem]
    
    // Action State
    @State private var itemToDelete: ClothingItem?
    @State private var itemToAssign: ClothingItem?
    
    // Sheet State
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingCalendarSheet = false
    
    // Calendar State
    @State private var selectedDate = Date()
    
    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]
    
    init(sort: [SortDescriptor<ClothingItem>], predicate: Predicate<ClothingItem>?) {
        _items = Query(filter: predicate, sort: sort)
    }
    
    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Items Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters")
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(items) { item in
                            NavigationLink(destination: ItemDetailView(item: item)) {
                                ItemCard(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        item.isArchived.toggle()
                                    }
                                } label: {
                                    Label(
                                        item.isArchived ? "Unarchive" : "Archive",
                                        systemImage: item.isArchived ? "arrow.up.bin" : "archivebox"
                                    )
                                }
                                
                                Button {
                                    itemToAssign = item
                                    isShowingCalendarSheet = true
                                } label: {
                                    Label("Assign to Calendar", systemImage: "calendar")
                                }
                                
                                Button(role: .destructive) {
                                    itemToDelete = item
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
            "Delete Item?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    modelContext.delete(item)
                }
                itemToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
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
                            itemToAssign = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let item = itemToAssign {
                                let log = DailyLog(date: selectedDate, items: [item])
                                modelContext.insert(log)
                            }
                            isShowingCalendarSheet = false
                            itemToAssign = nil
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct ItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        GeometryReader { geometry in
            if let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipped()
            } else {
                ZStack {
                    Color(.systemGray6)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
        }

        .aspectRatio(1, contentMode: .fit)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ItemGridView(sort: [], predicate: nil)
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
