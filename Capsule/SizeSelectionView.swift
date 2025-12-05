//
//  SizeSelectionView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI

struct SizeSelectionView: View {
    @Binding var selectedSize: String
    let category: MainCategory
    @Environment(\.dismiss) private var dismiss
    
    @State private var region: SizeRegion = .intl
    @State private var customSize: String = ""
    
    enum SizeRegion: String, CaseIterable, Identifiable {
        case intl = "INTL"
        case eu = "EU"
        case us = "US"
        case uk = "UK"
        case inches = "Inches" // For jeans/waist
        
        var id: String { rawValue }
    }
    
    // Logic to determine available regions based on category
    var availableRegions: [SizeRegion] {
        switch category {
        case .footwear:
            return [.eu, .us, .uk]
        case .bottom, .sport:
            return [.intl, .eu, .us, .uk, .inches]
        case .accessory, .nightwear:
            return [] // Often S/M/L or One Size
        case .underwear:
            return [.intl, .eu, .us, .uk]
        default:
            return [.intl, .eu, .us, .uk]
        }
    }
    
    var sizes: [String] {
        switch category {
        case .footwear:
            switch region {
            case .eu: return (35...46).map { String($0) }
            case .us: return stride(from: 4.0, through: 13.0, by: 0.5).map { $0.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", $0) : String($0) }
            case .uk: return stride(from: 2.0, through: 12.0, by: 0.5).map { $0.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", $0) : String($0) }
            default: return []
            }
            
        case .top, .bottom, .outerwear, .fullBody, .nightwear, .underwear, .sport:
            switch region {
            case .intl: return ["XXS", "XS", "S", "M", "L", "XL", "XXL", "3XL"]
            case .eu: return stride(from: 32, through: 54, by: 2).map { String($0) }
            case .us: return stride(from: 0, through: 20, by: 2).map { String($0) }
            case .uk: return stride(from: 4, through: 24, by: 2).map { String($0) }
            default: return []
            }
        default:
            return []
        }
    }
            
    // Separate data sources for Inches
    var waistSizes: [String] {
        stride(from: 24, through: 40, by: 1).map { String($0) }
    }
    
    var lengthSizes: [String] {
        stride(from: 28, through: 36, by: 2).map { String($0) }
    }
    
    // Helper to manage W/L selection
    @State private var tempWaist: String?
    @State private var tempLength: String?
    
    var body: some View {
        List {
            // Region Picker
            if !availableRegions.isEmpty {
                Section {
                    Picker("Region", selection: $region) {
                        ForEach(availableRegions) { region in
                            Text(region.rawValue).tag(region)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
                .onChange(of: region) {
                    // Reset temp selection when switching regions significantly
                    // (Optional logic, maybe keep it clean)
                }
            }
            
            // Special UI for Inches (Waist + Length)
            if region == .inches {
                Section("Waist") {
                    sizeGrid(sizes: waistSizes, selected: tempWaist) { s in
                        if tempWaist == s { tempWaist = nil } else { tempWaist = s }
                        updateCompositeSize()
                    }
                }
                
                Section("Length (Optional)") {
                    sizeGrid(sizes: lengthSizes, selected: tempLength) { s in
                        if tempLength == s { tempLength = nil } else { tempLength = s }
                        updateCompositeSize()
                    }
                }
                
            } else {
                // Standard Grid for everything else
                Section("Select Size") {
                    sizeGrid(sizes: sizes, selected: selectedSize) { s in
                        selectedSize = s
                        dismiss()
                    }
                }
            }
            
            // Custom Entry
            Section("Custom") {
                HStack {
                    TextField("Enter custom size...", text: $customSize)
                        .submitLabel(.done)
                        .onSubmit {
                            if !customSize.isEmpty {
                                selectedSize = customSize
                                dismiss()
                            }
                        }
                    
                    if !customSize.isEmpty {
                        Button("Use") {
                            selectedSize = customSize
                            dismiss()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("Select Size")
        .toolbar {
            if region == .inches {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            setupInitialRegionAndSelection()
        }
    }
    
    // extracted grid for reuse
    func sizeGrid(sizes: [String], selected: String?, action: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
            ForEach(sizes, id: \.self) { size in
                Button {
                    action(size)
                } label: {
                    Text(size)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(selected == size ? Color.blue : Color(.systemGray6))
                        .foregroundStyle(selected == size ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }
    
    func updateCompositeSize() {
        var parts: [String] = []
        if let w = tempWaist { parts.append("W\(w)") }
        if let l = tempLength { parts.append("L\(l)") }
        selectedSize = parts.joined(separator: " ")
    }
    
    func setupInitialRegionAndSelection() {
        // Defaults
        if category == .footwear { region = .eu }
        else if category == .bottom && region == .intl { region = .inches } // Default to inches for bottoms? Or stick to intl? User seemed to like inches logic.
        
        // Parse existing selection if it looks like W/L
        if selectedSize.contains("W") || selectedSize.contains("L") {
            // simple check, assumes format "W32 L32" or "W32"
            let components = selectedSize.components(separatedBy: " ")
            for comp in components {
                if comp.starts(with: "W") { tempWaist = String(comp.dropFirst()) }
                if comp.starts(with: "L") { tempLength = String(comp.dropFirst()) }
            }
            if !components.isEmpty { region = .inches }
        }
    }
}

#Preview {
    NavigationStack {
        SizeSelectionView(selectedSize: .constant("M"), category: .top)
    }
}
