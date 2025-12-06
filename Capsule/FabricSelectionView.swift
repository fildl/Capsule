//
//  FabricSelectionView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct FabricSelectionView: View {
    @Binding var materialComposition: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var composition: [FabricComponent] = []
    
    // Struct to hold temporary selection data
    struct FabricComponent: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var percentage: String = "" // String to allow empty state for typing
    }
    
    let commonFabrics = [
        "Cotton", "Polyester", "Elastane", "Wool", "Viscose", 
        "Linen", "Silk", "Nylon", "Acrylic", "Rayon", 
        "Spandex", "Leather", "Denim", "Cashmere", "Velvet", 
        "Satin", "Chiffon", "Corduroy", "Fleece", "Lace", 
        "Lyocell", "Modal", "Suede", "Tweed"
    ].sorted()
    
    var filteredFabrics: [String] {
        if searchText.isEmpty {
            return commonFabrics
        } else {
            return commonFabrics.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            // Selected Fabrics / Composition Builder
            if !composition.isEmpty {
                Section("Composition") {
                    ForEach($composition) { $component in
                        HStack {
                            Text(component.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            TextField("%", text: $component.percentage)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 50)
                                .textFieldStyle(.roundedBorder)
                            
                            Text("%")
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if let idx = composition.firstIndex(of: component) {
                                    composition.remove(at: idx)
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 8)
                        }
                    }
                }
            }
            
            // Available Fabrics
            Section("Add Fabric") {
                ForEach(filteredFabrics, id: \.self) { fabric in
                    Button {
                        addFabric(fabric)
                    } label: {
                        HStack {
                            Text(fabric)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            
            // Custom Fabric Logic
            if !searchText.isEmpty && !filteredFabrics.contains(where: { $0.localizedCaseInsensitiveCompare(searchText) == .orderedSame }) {
                Section {
                    Button("Add custom '\(searchText)'") {
                        addFabric(searchText)
                        searchText = ""
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Fabric")
        .navigationTitle("Select Fabric")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveComposition()
                    dismiss()
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            parseExistingComposition()
        }
    }
    
    func addFabric(_ name: String) {
        if !composition.contains(where: { $0.name == name }) {
            composition.append(FabricComponent(name: name))
        }
    }
    
    func saveComposition() {
        // Format: "80% Cotton, 20% Polyester" or just "Cotton, Polyester" if no % provided
        let parts = composition.map { component -> String in
            if !component.percentage.isEmpty {
                return "\(component.percentage)% \(component.name)"
            } else {
                return component.name
            }
        }
        materialComposition = parts.joined(separator: ", ")
    }
    
    func parseExistingComposition() {
        guard !materialComposition.isEmpty else { return }
        
        // Basic parsing logic
        // Expects format "80% Cotton, 20% Polyester" or "Cotton, Polyester"
        let parts = materialComposition.components(separatedBy: ",")
        
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            // Check if starts with percentage
            if let percentageRange = trimmed.range(of: "^\\d+%", options: .regularExpression) {
                let percentageStr = String(trimmed[percentageRange]).dropLast() // remove %
                let nameStr = String(trimmed[percentageRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                composition.append(FabricComponent(name: nameStr, percentage: String(percentageStr)))
            } else {
                // No percentage found, treat whole string as name
                composition.append(FabricComponent(name: trimmed))
            }
        }
    }
}

#Preview {
    NavigationStack {
        FabricSelectionView(materialComposition: .constant("80% Cotton, 20% Polyester"))
    }
}
