//
//  Models.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Enums

enum MainCategory: String, Codable, CaseIterable, Identifiable {
    case top = "Top"
    case bottom = "Bottom"
    case fullBody = "Full Body"
    case footwear = "Footwear"
    case accessory = "Accessory"
    case outerwear = "Outerwear"
    case underwear = "Underwear"
    case nightwear = "Nightwear"
    case sport = "Sport"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .top: return "tshirt"
        case .bottom: return "trousers" // Custom logic might be needed if SF Symbols doesn't match perfectly, usually pants or figure.walk
        case .fullBody: return "figure.dress"
        case .footwear: return "shoe"
        case .accessory: return "bag"
        case .outerwear: return "jacket"
        case .underwear: return "heart" // Placeholder
        case .nightwear: return "moon"
        case .sport: return "figure.run"
        }
    }
    
    var defaultSubcategories: [String] {
        switch self {
        case .top: return ["T-Shirt", "Shirt", "Sweater", "Hoodie", "Cardigan", "Blouse", "Tank Top", "Blazer"]
        case .bottom: return ["Jeans", "Trousers", "Shorts", "Skirt", "Leggings", "Joggers"]
        case .footwear: return ["Sneakers", "Boots", "Loafers", "Sandals", "Heels", "Flats"]
        case .outerwear: return ["Coat", "Jacket", "Trench", "Puffer", "Vest", "Raincoat"]
        case .accessory: return ["Bag", "Belt", "Hat", "Scarf", "Jewelry", "Sunglasses", "Tie"]
        case .fullBody: return ["Dress", "Jumpsuit", "Romper", "Suit"]
        case .underwear: return ["Briefs", "Boxers", "Socks", "Bra", "Panties"]
        case .nightwear: return ["Pajamas", "Robe", "Nightgown"]
        case .sport: return ["Sports Bra", "Leggings", "Shorts", "Top"]
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

enum CareWashingMethod: String, Codable, CaseIterable, Identifiable {
    case machine = "Machine Wash"
    case hand = "Hand Wash"
    case dontWash = "Do Not Wash"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .machine: return "washer"
        case .hand: return "hand.raised"
        case .dontWash: return "xmark.circle"
        }
    }
}

enum CareTemperature: String, Codable, CaseIterable, Identifiable {
    case cold = "Cold"
    case warm30 = "30°C"
    case warm40 = "40°C"
    case hot60 = "60°C"
    case hot90 = "90°C"
    
    var id: String { rawValue }
}

enum CareBleaching: String, Codable, CaseIterable, Identifiable {
    case allowed = "Bleach Allowed"
    case nonChlorine = "Non-Chlorine Only"
    case dontBleach = "Do Not Bleach"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .allowed: return "triangle"
        case .nonChlorine: return "triangle.fill" // Approximation
        case .dontBleach: return "xmark.bin" // Approximation, triangle with X is hard without custom symbol
        }
    }
}

enum CareDrying: String, Codable, CaseIterable, Identifiable {
    case tumbleLow = "Tumble Low"
    case tumbleMedium = "Tumble Medium"
    case tumbleHigh = "Tumble High"
    case lineDry = "Line Dry"
    case flatDry = "Flat Dry"
    case dontTumble = "Do Not Tumble"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .tumbleLow, .tumbleMedium, .tumbleHigh: return "fanblades" // Approximation for tumble
        case .lineDry: return "tshirt"
        case .flatDry: return "square.dashed"
        case .dontTumble: return "xmark.circle"
        }
    }
}

enum CareIroning: String, Codable, CaseIterable, Identifiable {
    case low = "Low Heat"
    case medium = "Medium Heat"
    case high = "High Heat"
    case noSteam = "No Steam"
    case no = "No Iron"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .low: return "thermometer.low"
        case .medium: return "thermometer.medium"
        case .high: return "thermometer.high"
        case .noSteam: return "drop.slash"
        case .no: return "xmark.circle"
        }
    }
}

enum ClothingColor: String, CaseIterable, Identifiable {
    // Neutrals
    case black = "Black"
    case charcoal = "Charcoal"
    case gray = "Gray"
    case white = "White"
    case cream = "Cream"
    case beige = "Beige"
    case tan = "Tan"
    case brown = "Brown"
    
    // Blues
    case navy = "Navy"
    case blue = "Blue"
    case denim = "Denim"
    case lightBlue = "Light Blue"
    case teal = "Teal"
    
    // Greens
    case darkGreen = "Dark Green"
    case green = "Green"
    case olive = "Olive"
    case mint = "Mint"
    case lime = "Lime"
    
    // Reds/Pinks
    case red = "Red"
    case burgundy = "Burgundy"
    case coral = "Coral"
    case pink = "Pink"
    case magenta = "Magenta"
    
    // Purples
    case purple = "Purple"
    case lavender = "Lavender"
    
    // Yellows/Oranges
    case yellow = "Yellow"
    case orange = "Orange"
    
    // Metallics
    case gold = "Gold"
    case silver = "Silver"
    case roseGold = "Rose Gold"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .black: return .black
        case .charcoal: return Color(white: 0.2)
        case .gray: return .gray
        case .white: return .white
        case .cream: return Color(red: 0.99, green: 0.99, blue: 0.90)
        case .beige: return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .tan: return Color(red: 0.82, green: 0.71, blue: 0.55)
        case .brown: return .brown
            
        case .navy: return Color(red: 0, green: 0, blue: 0.5)
        case .blue: return .blue
        case .denim: return Color(red: 0.24, green: 0.35, blue: 0.50)
        case .lightBlue: return .cyan
        case .teal: return Color(red: 0, green: 0.5, blue: 0.5)
            
        case .darkGreen: return Color(red: 0, green: 0.39, blue: 0)
        case .green: return .green
        case .olive: return Color(red: 0.5, green: 0.5, blue: 0)
        case .mint: return Color(red: 0.6, green: 1.0, blue: 0.8)
        case .lime: return Color(red: 0.75, green: 1.0, blue: 0)
            
        case .red: return .red
        case .burgundy: return Color(red: 0.5, green: 0, blue: 0.13)
        case .coral: return Color(red: 1, green: 0.5, blue: 0.31)
        case .pink: return .pink
        case .magenta: return Color(red: 1.0, green: 0.0, blue: 1.0)
            
        case .purple: return .purple
        case .lavender: return Color(red: 0.9, green: 0.9, blue: 0.98)
            
        case .yellow: return .yellow
        case .orange: return .orange
        
        case .gold: return Color(red: 1, green: 0.84, blue: 0)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .roseGold: return Color(red: 0.72, green: 0.45, blue: 0.45)
        }
    }
}

// MARK: - Models

// MARK: - Constants

let popularBrands = [
    "Abercrombie & Fitch", "Adidas", "Aeropostale", "Aldo", "Alexander McQueen", "Alo Yoga", "American Apparel", "American Eagle", "Anthropologie", "Armani", "Asos",
    "Balenciaga", "Banana Republic", "Barbour", "Bershka", "Billabong", "Birkenstock", "Boss", "Bottega Veneta", "Brooks Brothers", "Burberry",
    "Calvin Klein", "Canada Goose", "Carhartt", "Cartier", "Celine", "Champion", "Chanel", "Chloe", "Christian Louboutin", "Coach", "Columbia", "Common Projects", "Converse", "Cos", "Crocs",
    "Desigual", "Dickies", "Dior", "Doc Martens", "Dolce & Gabbana", "Dr. Martens", "Dsquared2",
    "Everlane",
    "Fendi", "Fila", "Forever 21", "Free People", "Fred Perry", "Fruit of the Loom",
    "Gant", "Gap", "Givenchy", "Gucci", "Guess", "Gymshark",
    "H&M", "Hermès", "Hollister", "Hugo Boss", "Hunter",
    "Isabel Marant",
    "J.Crew", "Jimmy Choo", "Jordan",
    "Kate Spade", "Kenzo",
    "Lacoste", "Lee", "Levi's", "Loewe", "Louis Vuitton", "Lululemon",
    "Mango", "Marc Jacobs", "Marni", "Massimo Dutti", "Michael Kors", "Miu Miu", "Moncler", "Moschino", "Mother",
    "New Balance", "Nike", "North Face",
    "Oakley", "Off-White", "Old Navy", "Omega", "Only",
    "Pandora", "Patagonia", "Paul Smith", "Pepe Jeans", "Prada", "Primaesha", "Primark", "Pull & Bear", "Puma",
    "Ralph Lauren", "Ray-Ban", "Reebok", "Reformation", "River Island", "Rolex",
    "Saint Laurent", "Salvatore Ferragamo", "Sandro", "Scotch & Soda", "Seiko", "Shein", "Skechers", "Stella McCartney", "Stone Island", "Stussy", "Superdry", "Supreme", "Swarovski",
    "Ted Baker", "The North Face", "Tiffany & Co.", "Timberland", "Tommy Hilfiger", "Toms", "Topman", "Topshop", "Tory Burch",
    "Under Armour", "Uniqlo", "Urban Outfitters",
    "Valentino", "Vans", "Versace", "Vetements", "Victoria's Secret", "Vivienne Westwood", "Vogue",
    "Weekday", "Woolrich",
    "Yeezy", "YSL",
    "Zara", "Zegna"
]

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
    var purchaseLocation: String?
    var purchaseUrl: URL?
    var purchaseDate: Date?
    
    // Care
    // Care
    var careWashingMethodRaw: String?
    var careTemperatureRaw: String?
    var careBleachingRaw: String?
    var careDryingRaw: String?
    var careIroningRaw: String?
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
    
    var washingMethod: CareWashingMethod {
        get { CareWashingMethod(rawValue: careWashingMethodRaw ?? "") ?? .machine }
        set { careWashingMethodRaw = newValue.rawValue }
    }
    
    var washingTemperature: CareTemperature? {
        get { careTemperatureRaw != nil ? CareTemperature(rawValue: careTemperatureRaw!) : nil }
        set { careTemperatureRaw = newValue?.rawValue }
    }
    
    var bleaching: CareBleaching {
        get { CareBleaching(rawValue: careBleachingRaw ?? "") ?? .dontBleach }
        set { careBleachingRaw = newValue.rawValue }
    }
    
    var drying: CareDrying {
        get { CareDrying(rawValue: careDryingRaw ?? "") ?? .dontTumble }
        set { careDryingRaw = newValue.rawValue }
    }
    
    var ironing: CareIroning {
        get { CareIroning(rawValue: careIroningRaw ?? "") ?? .no }
        set { careIroningRaw = newValue.rawValue }
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
        purchaseLocation: String? = nil,
        purchaseUrl: URL? = nil,
        purchaseDate: Date? = nil,
        washingMethod: CareWashingMethod? = nil,
        washingTemperature: CareTemperature? = nil,
        bleaching: CareBleaching? = nil,
        drying: CareDrying? = nil,
        ironing: CareIroning? = nil,
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
        self.purchaseLocation = purchaseLocation
        self.purchaseUrl = purchaseUrl
        self.purchaseDate = purchaseDate
        self.purchaseUrl = purchaseUrl
        self.purchaseDate = purchaseDate
        self.careWashingMethodRaw = washingMethod?.rawValue
        self.careTemperatureRaw = washingTemperature?.rawValue
        self.careBleachingRaw = bleaching?.rawValue
        self.careDryingRaw = drying?.rawValue
        self.careIroningRaw = ironing?.rawValue
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
