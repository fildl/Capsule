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
