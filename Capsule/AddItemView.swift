//
//  AddItemView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Image State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // MARK: - Form State
    @State private var mainCategory: MainCategory = .top
    @State private var subCategory: String = ""
    @State private var brand: String = ""
    @State private var size: String = ""
    @State private var materialComposition: String = ""
    @State private var price: Decimal?
    @State private var purchaseStatus: PurchaseStatus = .new
    @State private var purchaseUrlString: String = ""
    @State private var washingMode: WashingMode = .machine30
    @State private var ironing: Ironing = .no
    @State private var careNotes: String = ""
    @State private var notes: String = ""
    
    // MARK: - Collections
    @State private var selectedSeasons: Set<Season> = []
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Image
                Section {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets())
                    }
                    
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            selectedImageData == nil ? "Add Photo" : "Change Photo",
                            systemImage: "photo"
                        )
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                // Section 2: Basic Info
                Section("Categorization") {
                    Picker("Category", selection: $mainCategory) {
                        ForEach(MainCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextField("Subcategory (e.g. Jeans, T-Shirt)", text: $subCategory)
                }
                
                // Section 3: Details
                Section("Details") {
                    TextField("Brand", text: $brand)
                    TextField("Size", text: $size)
                    TextField("Material (e.g. 100% Cotton)", text: $materialComposition)
                    
                    // Seasons Multi-Select
                    DisclosureGroup("Seasons") {
                        ForEach(Season.allCases) { season in
                            Toggle(season.rawValue, isOn: Binding(
                                get: { selectedSeasons.contains(season) },
                                set: { isOn in
                                    if isOn {
                                        selectedSeasons.insert(season)
                                    } else {
                                        selectedSeasons.remove(season)
                                    }
                                }
                            ))
                        }
                    }
                }
                
                // Section 4: Purchase Info
                Section("Purchase Info") {
                    TextField("Price", value: $price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                        .keyboardType(.decimalPad)
                    
                    Picker("Status", selection: $purchaseStatus) {
                        ForEach(PurchaseStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("URL", text: $purchaseUrlString)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                // Section 5: Care
                Section("Care Instructions") {
                    Picker("Washing", selection: $washingMode) {
                        ForEach(WashingMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    Picker("Ironing", selection: $ironing) {
                        ForEach(Ironing.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    TextField("Care Notes", text: $careNotes, axis: .vertical)
                }
                
                // Section 6: Notes
                Section("Notes") {
                    TextField("General Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(selectedImageData == nil && subCategory.isEmpty) // Minimum validation
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = ClothingItem(
            imageData: selectedImageData,
            mainCategory: mainCategory,
            subCategory: subCategory,
            brand: brand.isEmpty ? nil : brand,
            size: size.isEmpty ? nil : size,
            colors: [], // TODO: Add Color Picker
            materialComposition: materialComposition.isEmpty ? nil : materialComposition,
            seasons: selectedSeasons,
            price: price,
            purchaseStatus: purchaseStatus,
            purchaseUrl: URL(string: purchaseUrlString),
            washingMode: washingMode,
            ironing: ironing,
            careNotes: careNotes.isEmpty ? nil : careNotes,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(newItem)
        dismiss()
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
