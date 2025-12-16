//
//  TagSelectionView.swift
//  Capsule
//
//  Created by Capsule Assistant on 16/12/25.
//

import SwiftUI
import SwiftData

struct TagSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    
    @Binding var selectedTags: [Tag]
    
    @State private var searchText = ""
    
    var filteredTags: [Tag] {
        if searchText.isEmpty {
            return allTags
        } else {
            return allTags.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            // Selected Tags Section
            if !selectedTags.isEmpty {
                Section("Selected Tags") {
                    ForEach(selectedTags) { tag in
                        HStack {
                            Text(tag.name)
                            Spacer()
                            Button {
                                if let idx = selectedTags.firstIndex(of: tag) {
                                    selectedTags.remove(at: idx)
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Available Tags
            Section("All Tags") {
                ForEach(filteredTags) { tag in
                    HStack {
                        Text(tag.name)
                        Spacer()
                        if selectedTags.contains(tag) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        } else {
                             Button {
                                selectedTags.append(tag)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Create New Tag Logic
            if !searchText.isEmpty && !allTags.contains(where: { $0.name.localizedCaseInsensitiveCompare(searchText) == .orderedSame }) {
                Section {
                    Button("Create tag '\(searchText)'") {
                        let newTag = Tag(name: searchText)
                        modelContext.insert(newTag)
                        selectedTags.append(newTag)
                        searchText = ""
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search or create tag")
        .navigationTitle("Tags")
    }
}
