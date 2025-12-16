//
//  TagManagementView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 06/12/25.
//

import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]
    
    @State private var tagToRename: Tag?
    @State private var newTagName: String = ""
    @State private var isShowingRenameAlert = false
    
    @State private var tagToDelete: Tag?
    @State private var isShowingDeleteConfirmation = false
    
    var body: some View {
        List {
            ForEach(tags) { tag in
                TagListRow(
                    tag: tag,
                    onRename: {
                        tagToRename = tag
                        newTagName = tag.name
                        isShowingRenameAlert = true
                    },
                    onDelete: {
                        tagToDelete = tag
                        isShowingDeleteConfirmation = true
                    }
                )
            }
        }
        .navigationTitle("Manage Tags")
        .overlay {
            if tags.isEmpty {
                ContentUnavailableView(
                    "No Tags",
                    systemImage: "tag",
                    description: Text("You haven't created any tags yet.")
                )
            }
        }
        // Rename Alert
        .alert("Edit Tag", isPresented: $isShowingRenameAlert) {
            TextField("New Name", text: $newTagName)
            Button("Cancel", role: .cancel) {
                tagToRename = nil
                newTagName = ""
            }
            Button("Rename") {
                if let tag = tagToRename, !newTagName.isEmpty {
                    tag.name = newTagName
                }
                tagToRename = nil
                newTagName = ""
            }
        } message: {
            Text("Enter a new name for this tag.")
        }
        // Delete Confirmation
        .confirmationDialog(
            "Delete Tag?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let tag = tagToDelete {
                    modelContext.delete(tag)
                }
                tagToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                tagToDelete = nil
            }
        } message: {
            deleteConfirmationMessage
        }
    }
    
    private var deleteConfirmationMessage: some View {
        if let tag = tagToDelete {
            let itemsCount = tag.items?.count ?? 0
            let outfitsCount = tag.outfits?.count ?? 0
            
            if itemsCount > 0 || outfitsCount > 0 {
                var parts: [String] = []
                if itemsCount > 0 {
                    parts.append("\(itemsCount) item\(itemsCount == 1 ? "" : "s")")
                }
                if outfitsCount > 0 {
                    parts.append("\(outfitsCount) outfit\(outfitsCount == 1 ? "" : "s")")
                }
                
                let usageString = parts.joined(separator: " and ")
                return Text("This tag is used in \(usageString). Deleting it will remove it from all of them.")
            }
        }
        return Text("Are you sure you want to delete this tag?")
    }
}

struct TagListRow: View {
    let tag: Tag
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(tag.name)
                .font(.body)
            
            Spacer()
            
            // Usage Counts
            HStack(spacing: 12) {
                if let count = tag.items?.count, count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "tshirt")
                            .font(.caption)
                        Text("\(count)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                
                if let count = tag.outfits?.count, count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2")
                            .font(.caption)
                        Text("\(count)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle()) // Make full row tapable for context menu
        .contextMenu {
            Button {
                onRename()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onRename()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    NavigationStack {
        TagManagementView()
            .modelContainer(for: Tag.self, inMemory: true)
    }
}
