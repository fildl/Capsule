//
//  ItemDetailView.swift
//  Capsule
//
//  Created by Capsule Assistant on 06/12/25.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Bindable var item: ClothingItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("temperatureUnit") private var temperatureUnit = "C"
    
    @State private var isShowingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Hero
                Group {
                    if let data = item.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        ZStack {
                            Color(.systemGray5)
                                .frame(height: 300)
                                .cornerRadius(12)
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header: Brand & Name
                    VStack(alignment: .leading, spacing: 8) {
                        if let brand = item.brand, !brand.isEmpty {
                            Text(brand.uppercased())
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .tracking(1.5)
                        }
                        
                        Text(item.subCategory.isEmpty ? item.mainCategory.rawValue : item.subCategory)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                    }
                    
                    Divider()
                    
                    // Basic Info Row
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 24) {
                        InfoRow(title: "Category", value: item.mainCategory.rawValue)
                        
                        if !item.subCategory.isEmpty {
                            InfoRow(title: "Subcategory", value: item.subCategory)
                        }
                        
                        if let size = item.size, !size.isEmpty {
                            InfoRow(title: "Size", value: size)
                        }
                    }
                    
                    // Colors
                    if !item.colors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(item.colors, id: \.self) { colorName in
                                    if let colorEnum = ClothingColor(rawValue: colorName) {
                                        HStack {
                                            Circle()
                                                .fill(colorEnum.color)
                                                .frame(width: 24, height: 24)
                                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                            Text(colorEnum.rawValue)
                                                .font(.body)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Fabric (Was Materials)
                    if let materials = item.materialComposition, !materials.isEmpty {
                         VStack(alignment: .leading, spacing: 8) {
                            Text("FABRIC")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Text(materials)
                                .font(.body)
                        }
                        Divider()
                    }
                    
                    // Seasons
                    if !item.seasons.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SEASONS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(sortedSeasons(item.seasons), id: \.self) { season in
                                    Text(season)
                                        .font(.callout)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        Divider()
                    }
                    
                    // Purchase Info
                    if (item.purchaseLocation != nil && !item.purchaseLocation!.isEmpty) ||
                        item.purchaseUrl != nil ||
                        item.purchaseDate != nil ||
                        (item.price != nil && item.price! > 0) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PURCHASE INFO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            if let location = item.purchaseLocation, !location.isEmpty {
                                InfoRow(title: "Store / Website", value: location)
                            }
                            
                            if let url = item.purchaseUrl {
                                Button {
                                    UIApplication.shared.open(url)
                                } label: {
                                    HStack(alignment: .center, spacing: 4) {
                                        Image(systemName: "link")
                                        Text("Open Link")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                                .padding(.vertical, 2)
                            }
                            
                            if let date = item.purchaseDate {
                                InfoRow(title: "Date", value: date.formatted(date: .long, time: .omitted))
                            }
                            
                            if let price = item.price, price > 0 {
                                InfoRow(title: "Price", value: price.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR")))
                            }
                        }
                    }
                    
                    if item.careWashingMethodRaw != nil {
                        Divider()
                        
                        // Care
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CARE DETAILS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 20) {
                                // Washing
                                if let washing = CareWashingMethod(rawValue: item.careWashingMethodRaw ?? "") {
                                    CareIconView(icon: washing.icon, label: washing.rawValue)
                                }
                                // Temp
                                if let temp = CareTemperature(rawValue: item.careTemperatureRaw ?? "") {
                                    CareIconView(icon: "thermometer", label: temp.displayValue(for: temperatureUnit))
                                }
                                // Bleach
                                if let bleach = CareBleaching(rawValue: item.careBleachingRaw ?? "") {
                                    CareIconView(icon: bleach.icon, label: bleach.rawValue)
                                }
                            }
                            HStack(spacing: 20) {
                                // Drying
                                if let dry = CareDrying(rawValue: item.careDryingRaw ?? "") {
                                    CareIconView(icon: dry.icon, label: dry.rawValue)
                                }
                                // Ironing
                                if let iron = CareIroning(rawValue: item.careIroningRaw ?? "") {
                                    CareIconView(icon: iron.icon, label: iron.rawValue)
                                }
                            }
                            
                            if let notes = item.careNotes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = item.notes, !notes.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        // We will enable this once AddItemView is refactored
        .sheet(isPresented: $isShowingEditSheet) {
            AddItemView(itemToEdit: item)
        }
    }
    
    // Sort logic for display if needed
    func sortedSeasons(_ seasons: Set<Season>) -> [String] {
        let all = Season.allCases
        let sorted = all.filter { seasons.contains($0) }
        return sorted.map { $0.rawValue }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct CareIconView: View {
    let icon: String?
    let label: String
    
    var body: some View {
        VStack {
            if let icon {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            Text(label)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        if rows.isEmpty { return .zero }
        return CGSize(width: proposal.width ?? 0, height: rows.last?.maxY ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        for row in rows {
            for element in row.elements {
                element.subview.place(at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y), proposal: .unspecified)
            }
        }
    }
    
    struct Row {
        var elements: [Element] = []
        var maxY: CGFloat = 0
    }
    
    struct Element {
        var subview: LayoutSubview
        var x: CGFloat
        var y: CGFloat
    }
    
    func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentRow = Row()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowMaxH: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                // New row
                currentRow.maxY = currentY + rowMaxH
                rows.append(currentRow)
                currentRow = Row()
                currentX = 0
                currentY += rowMaxH + spacing
                rowMaxH = 0
            }
            
            currentRow.elements.append(Element(subview: subview, x: currentX, y: currentY))
            currentX += size.width + spacing
            rowMaxH = max(rowMaxH, size.height)
        }
        
        if !currentRow.elements.isEmpty {
            currentRow.maxY = currentY + rowMaxH
            rows.append(currentRow)
        }
        
        return rows
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
