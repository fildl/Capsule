//
//  Models.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Enums

enum MainCategory: String, Codable, CaseIterable, Identifiable {
    case top = "Top"
    case bottom = "Bottom"
    case shoes = "Shoes"
    case outerwear = "Outerwear"
    case accessory = "Accessory"
    case onePiece = "One Piece"
    
    var id: String { rawValue }
    
    var defaultSubcategories: [String] {
        switch self {
        case .top: return ["T-Shirt", "Shirt", "Sweater", "Hoodie", "Cardigan", "Blouse", "Tank Top", "Blazer"]
        case .bottom: return ["Jeans", "Trousers", "Shorts", "Skirt", "Leggings", "Joggers"]
        case .shoes: return ["Sneakers", "Boots", "Loafers", "Sandals", "Heels", "Flats"]
        case .outerwear: return ["Coat", "Jacket", "Trench", "Puffer", "Vest", "Raincoat"]
        case .accessory: return ["Bag", "Belt", "Hat", "Scarf", "Jewelry", "Sunglasses", "Tie"]
        case .onePiece: return ["Dress", "Jumpsuit", "Romper", "Suit"]
        }
    }
}

enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
    
    var id: String { rawValue }
}

enum PurchaseStatus: String, Codable, CaseIterable, Identifiable {
    case new = "New"
    case used = "Second Hand"
    case gift = "Gift"
    case handmade = "Handmade"
    
    var id: String { rawValue }
}

enum WashingMode: String, Codable, CaseIterable, Identifiable {
    case machine30 = "Machine 30°"
    case machine40 = "Machine 40°"
    case handWash = "Hand Wash"
    case dryClean = "Dry Clean"
    case dontWash = "Do Not Wash"
    
    var id: String { rawValue }
}

enum Ironing: String, Codable, CaseIterable, Identifiable {
    case no = "No Iron"
    case low = "Low Heat"
    case medium = "Medium Heat"
    case high = "High Heat"
    
    var id: String { rawValue }
}

enum ClothingColor: String, CaseIterable, Identifiable {
    case black = "Black"
    case white = "White"
    case gray = "Gray"
    case navy = "Navy"
    case blue = "Blue"
    case lightBlue = "Light Blue"
    case red = "Red"
    case burgundy = "Burgundy"
    case beige = "Beige"
    case brown = "Brown"
    case green = "Green"
    case olive = "Olive"
    case yellow = "Yellow"
    case orange = "Orange"
    case purple = "Purple"
    case pink = "Pink"
    case gold = "Gold"
    case silver = "Silver"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        case .gray: return .gray
        case .navy: return Color(red: 0, green: 0, blue: 0.5)
        case .blue: return .blue
        case .lightBlue: return .cyan
        case .red: return .red
        case .burgundy: return Color(red: 0.5, green: 0, blue: 0.13)
        case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .brown: return .brown
        case .green: return .green
        case .olive: return Color(red: 0.5, green: 0.5, blue: 0)
        case .yellow: return .yellow
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .gold: return Color(red: 1, green: 0.84, blue: 0)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        }
    }
}

// MARK: - Models

@Model
final class ClothingItem {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    
    // Categorization
    var mainCategoryRaw: String
    var subCategory: String
    
    // Details
    var brand: String?
    var size: String?
    var colors: [String] // Hex codes or names
    var materialComposition: String?
    var seasonsRaw: [String] // Stored as array of raw strings
    
    // Purchase Info
    var price: Decimal?
    var purchaseStatusRaw: String
    var purchaseUrl: URL?
    var purchaseDate: Date?
    
    // Care
    var washingModeRaw: String
    var ironingRaw: String
    var careNotes: String?
    
    // Meta
    var notes: String?
    var isArchived: Bool = false
    var createdAt: Date = Date()
    
    // Relationships
    @Relationship(inverse: \Outfit.items) var outfits: [Outfit]?
    
    // Computed Properties for Enums
    var mainCategory: MainCategory {
        get { MainCategory(rawValue: mainCategoryRaw) ?? .top }
        set { mainCategoryRaw = newValue.rawValue }
    }
    
    var seasons: Set<Season> {
        get { Set(seasonsRaw.compactMap { Season(rawValue: $0) }) }
            set { seasonsRaw = newValue.map { $0.rawValue } }
    }
    
    var purchaseStatus: PurchaseStatus {
        get { PurchaseStatus(rawValue: purchaseStatusRaw) ?? .new }
        set { purchaseStatusRaw = newValue.rawValue }
    }
    
    var washingMode: WashingMode {
        get { WashingMode(rawValue: washingModeRaw) ?? .machine30 }
        set { washingModeRaw = newValue.rawValue }
    }
    
    var ironing: Ironing {
        get { Ironing(rawValue: ironingRaw) ?? .no }
        set { ironingRaw = newValue.rawValue }
    }
    
    init(
        imageData: Data? = nil,
        mainCategory: MainCategory = .top,
        subCategory: String = "",
        brand: String? = nil,
        size: String? = nil,
        colors: [String] = [],
        materialComposition: String? = nil,
        seasons: Set<Season> = [],
        price: Decimal? = nil,
        purchaseStatus: PurchaseStatus = .new,
        purchaseUrl: URL? = nil,
        purchaseDate: Date? = nil,
        washingMode: WashingMode = .machine30,
        ironing: Ironing = .no,
        careNotes: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.mainCategoryRaw = mainCategory.rawValue
        self.subCategory = subCategory
        self.brand = brand
        self.size = size
        self.colors = colors
        self.materialComposition = materialComposition
        self.seasonsRaw = seasons.map { $0.rawValue }
        self.price = price
        self.purchaseStatusRaw = purchaseStatus.rawValue
        self.purchaseUrl = purchaseUrl
        self.purchaseDate = purchaseDate
        self.washingModeRaw = washingMode.rawValue
        self.ironingRaw = ironing.rawValue
        self.careNotes = careNotes
        self.notes = notes
    }
}

@Model
final class Outfit {
    var id: UUID
    var seasonsRaw: [String]
    var notes: String?
    var isFavorite: Bool = false
    var createdAt: Date = Date()
    
    @Relationship var items: [ClothingItem]?
    @Relationship(inverse: \DailyLog.outfit) var logs: [DailyLog]?
    
    var seasons: Set<Season> {
        get { Set(seasonsRaw.compactMap { Season(rawValue: $0) }) }
        set { seasonsRaw = newValue.map { $0.rawValue } }
    }
    
    init(items: [ClothingItem] = [], seasons: Set<Season> = [], notes: String? = nil) {
        self.id = UUID()
        self.items = items
        self.seasonsRaw = seasons.map { $0.rawValue }
        self.notes = notes
    }
}

@Model
final class DailyLog {
    var date: Date
    @Relationship var outfit: Outfit?
    
    // We might want to allow logging individual items without an outfit wrapper in future,
    // but for now we follow the plan: Log -> Outfit -> Items
    
    init(date: Date, outfit: Outfit?) {
        self.date = date
        self.outfit = outfit
    }
}
