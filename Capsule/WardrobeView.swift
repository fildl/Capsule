//
//  WardrobeView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI

struct WardrobeView: View {
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("View Mode", selection: $selectedSegment) {
                    Text("Items").tag(0)
                    Text("Outfits").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedSegment == 0 {
                    ContentUnavailableView(
                        "No Items Yet",
                        systemImage: "tshirt",
                        description: Text("Tap + to add your first item")
                    )
                } else {
                    ContentUnavailableView(
                        "No Outfits Yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Create outfits from your items")
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Add Item Action
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
                .padding(.bottom, 8) 
            }
        }
    }
}

#Preview {
    WardrobeView()
}
