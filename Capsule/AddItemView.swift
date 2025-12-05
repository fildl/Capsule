//
//  AddItemView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
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
    @State private var originalImageData: Data?
    @State private var bgRemovedImageData: Data? // Cache for the full BG-removed image
    @State private var isBackgroundRemoved: Bool = false
    @State private var isProcessingImage: Bool = false
    @State private var isShowingEditor: Bool = false
    
    // Editor State
    @State private var currentCropScale: CGFloat = 1.0
    @State private var currentCropOffset: CGSize = .zero
    
    // MARK: - Form State
    @State private var mainCategory: MainCategory = .top
    @State private var subCategory: String = ""
    @State private var selectedColors: Set<ClothingColor> = []
    @State private var brand: String = ""
    @State private var size: String = ""
    @State private var materialComposition: String = ""
    @State private var price: Decimal?
    @State private var purchaseStatus: PurchaseStatus = .new
    @State private var purchaseLocation: String = ""
    @State private var purchaseUrlString: String = ""
    @State private var addPurchaseDate: Bool = false
    @State private var purchaseDate: Date = Date()
    @State private var washingMethod: CareWashingMethod = .machine
    @State private var washingTemperature: CareTemperature = .warm30
    @State private var bleaching: CareBleaching = .dontBleach
    @State private var drying: CareDrying = .dontTumble
    @State private var ironing: CareIroning = .no
    @State private var careNotes: String = ""
    @State private var notes: String = ""
    
    // MARK: - Collections
    @State private var selectedSeasons: Set<Season> = []
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Photo
                Section {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        ZStack(alignment: .bottomTrailing) {
                            // The Image is the trigger for changing photo
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 300)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                    
                                    if isProcessingImage {
                                        ZStack {
                                            Color.black.opacity(0.4)
                                            ProgressView()
                                                .tint(.white)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Edit Button - Outside PhotosPicker
                            Button {
                                isShowingEditor = true
                            } label: {
                                Image(systemName: "crop")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .background(.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                    } else {
                        // Placeholder Trigger
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                Text("Add Photo")
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color(.systemGray6))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                            withAnimation {
                                selectedImageData = data
                                originalImageData = data
                                bgRemovedImageData = nil // Reset cached BG removed
                                isBackgroundRemoved = false // Reset toggle
                                // Reset crop
                                currentCropScale = 1.0
                                currentCropOffset = .zero
                            }
                        }
                    }
                }
                
                if selectedImageData != nil {
                    Section {
                        Toggle(isOn: $isBackgroundRemoved) {
                            Text("Remove Background")
                        }
                        .disabled(isProcessingImage)
                        .onChange(of: isBackgroundRemoved) {
                            Task {
                                if isBackgroundRemoved {
                                    // Switch to BG Removed
                                    if let cached = bgRemovedImageData {
                                        // Already have it
                                        withAnimation {
                                            selectedImageData = cached
                                            // Reset crop when switching modes to be safe
                                            currentCropScale = 1.0
                                            currentCropOffset = .zero
                                        }
                                    } else {
                                        // Need to process
                                        guard let original = originalImageData else { return }
                                        isProcessingImage = true
                                        let processed = await ImageProcessing.removeBackground(from: original)
                                        withAnimation {
                                            if let processed {
                                                bgRemovedImageData = processed
                                                selectedImageData = processed
                                                // Reset crop
                                                currentCropScale = 1.0
                                                currentCropOffset = .zero
                                            }
                                            isProcessingImage = false
                                        }
                                    }
                                } else {
                                    // Revert to Original
                                    withAnimation {
                                        selectedImageData = originalImageData
                                        // Reset crop
                                        currentCropScale = 1.0
                                        currentCropOffset = .zero
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Section 2: Basic Info
                Section("Category") {
                    Picker("Category", selection: $mainCategory) {
                        ForEach(MainCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .onChange(of: mainCategory) {
                        subCategory = mainCategory.defaultSubcategories.first ?? ""
                    }
                    
                    Picker("Subcategory", selection: $subCategory) {
                        if subCategory.isEmpty {
                            Text("Select").tag("")
                        }
                        ForEach(mainCategory.defaultSubcategories, id: \.self) { sub in
                            Text(sub).tag(sub)
                        }
                    }
                }
                .onAppear {
                    if subCategory.isEmpty {
                        subCategory = mainCategory.defaultSubcategories.first ?? ""
                    }
                }
                
                // Section 3: Details
                Section("Details") {
                    NavigationLink {
                        ColorSelectionView(selectedColors: $selectedColors)
                    } label: {
                        if selectedColors.isEmpty {
                            HStack {
                                Text("Colors")
                                Spacer()
                                Text("Select")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(selectedColors).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { color in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(color.color)
                                                .frame(width: 16, height: 16)
                                                .overlay(Circle().stroke(Color.gray.opacity(0.2)))
                                            Text(color.rawValue)
                                                .font(.subheadline)
                                        }
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    NavigationLink {
                        BrandSelectionView(selectedBrand: $brand)
                    } label: {
                        HStack {
                            Text("Brand")
                            Spacer()
                            Text(brand.isEmpty ? "Select" : brand)
                                .foregroundStyle(brand.isEmpty ? .secondary : .primary)
                        }
                    }
                    
                    NavigationLink {
                        SizeSelectionView(selectedSize: $size, category: mainCategory)
                    } label: {
                        HStack {
                            Text("Size")
                            Spacer()
                            Text(size.isEmpty ? "Select" : size)
                                .foregroundStyle(size.isEmpty ? .secondary : .primary)
                        }
                    }
                    
                    
                    NavigationLink {
                        FabricSelectionView(materialComposition: $materialComposition)
                    } label: {
                        HStack {
                            Text("Fabric")
                            Spacer()
                            Text(materialComposition.isEmpty ? "Select" : materialComposition)
                                .foregroundStyle(materialComposition.isEmpty ? .secondary : .primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    
                    // Seasons Multi-Select
                    DisclosureGroup(content: {
                        Toggle("All Year", isOn: Binding(
                            get: { selectedSeasons.count == Season.allCases.count },
                            set: { isOn in
                                if isOn {
                                    selectedSeasons = Set(Season.allCases)
                                } else {
                                    selectedSeasons.removeAll()
                                }
                            }
                        ))
                        
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
                    }, label: {
                        HStack {
                            Text("Seasons")
                            Spacer()
                            Text(selectedSeasonsSummary)
                                .foregroundStyle(selectedSeasons.isEmpty ? .secondary : .primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    })
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
                    
                    TextField("Store / Website", text: $purchaseLocation)
                        .autocorrectionDisabled()
                    
                    TextField("URL", text: $purchaseUrlString)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    Toggle("Add Date", isOn: $addPurchaseDate.animation())
                    
                    if addPurchaseDate {
                        DatePicker("Date", selection: $purchaseDate, displayedComponents: .date)
                    }
                }
                
                Section("Care Details") {
                    Picker("Washing", selection: $washingMethod) {
                        ForEach(CareWashingMethod.allCases) { method in
                            Label(method.rawValue, systemImage: method.icon).tag(method)
                        }
                    }
                    
                    if washingMethod != .dontWash {
                        Picker("Temperature", selection: $washingTemperature) {
                            ForEach(CareTemperature.allCases) { temp in
                                Text(temp.rawValue).tag(temp)
                            }
                        }
                    }
                    
                    Picker("Bleaching", selection: $bleaching) {
                        ForEach(CareBleaching.allCases) { option in
                            Label(option.rawValue, systemImage: option.icon).tag(option)
                        }
                    }
                    
                    Picker("Drying", selection: $drying) {
                        ForEach(CareDrying.allCases) { option in
                            Label(option.rawValue, systemImage: option.icon).tag(option)
                        }
                    }
                    
                    Picker("Ironing", selection: $ironing) {
                        ForEach(CareIroning.allCases) { option in
                            Label(option.rawValue, systemImage: option.icon).tag(option)
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
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $isShowingEditor) {
            // Determine which base image to edit (Original or BG Removed)
            // This ensures we always start with the full image, allowing non-destructive zoom/pan
            let baseData = isBackgroundRemoved ? bgRemovedImageData : originalImageData
            
            if let baseData, let uiImage = UIImage(data: baseData) {
                ImageEditorView(
                    inputImage: uiImage,
                    initialScale: currentCropScale,
                    initialOffset: currentCropOffset
                ) { editedImage, newScale, newOffset in
                    withAnimation {
                        if let data = editedImage.pngData() {
                            // Update the display image
                            selectedImageData = data
                            // Persist the crop parameters so we can "resume" editing later
                            currentCropScale = newScale
                            currentCropOffset = newOffset
                        }
                    }
                }
            }
        }
    }
    
    private var selectedSeasonsSummary: String {
        if selectedSeasons.isEmpty {
            return "Select"
        } else if selectedSeasons.count == Season.allCases.count {
            return "All Year"
        } else {
            // Sort by the order in Season.allCases to keep it consistent
            let sortedSeasons = Season.allCases.filter { selectedSeasons.contains($0) }
            return sortedSeasons.map { $0.rawValue }.joined(separator: ", ")
        }
    }
    
    private func saveItem() {
        let newItem = ClothingItem(
            imageData: selectedImageData,
            mainCategory: mainCategory,
            subCategory: subCategory,
            brand: brand.isEmpty ? nil : brand,
            size: size.isEmpty ? nil : size,
            colors: selectedColors.map { $0.rawValue },
            materialComposition: materialComposition.isEmpty ? nil : materialComposition,
            seasons: selectedSeasons,
            price: price,
            purchaseStatus: purchaseStatus,
            purchaseLocation: purchaseLocation.isEmpty ? nil : purchaseLocation,
            purchaseUrl: URL(string: purchaseUrlString),
            purchaseDate: addPurchaseDate ? purchaseDate : nil,
            washingMethod: washingMethod,
            washingTemperature: washingMethod == .dontWash ? nil : washingTemperature,
            bleaching: bleaching,
            drying: drying,
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

struct ColorSelectionView: View {
    @Binding var selectedColors: Set<ClothingColor>
    
    var body: some View {
        List {
            ForEach(ClothingColor.allCases) { color in
                HStack {
                    Circle()
                        .fill(color.color)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.gray.opacity(0.3)))
                    
                    Text(color.rawValue)
                    
                    Spacer()
                    
                    if selectedColors.contains(color) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedColors.contains(color) {
                        selectedColors.remove(color)
                    } else {
                        selectedColors.insert(color)
                    }
                }
            }
        }
        .navigationTitle("Select Colors")
    }
}
