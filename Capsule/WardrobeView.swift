//
//  WardrobeView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct WardrobeView: View {
    @State private var selectedSegment = 0
    @State private var isShowingAddItem = false
    @State private var isShowingOutfitBuilder = false
    
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
                    ItemGridView()
                } else {
                    OutfitGridView()
                }
                
                Spacer()
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        if selectedSegment == 0 {
                            isShowingAddItem = true
                        } else {
                            isShowingOutfitBuilder = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $isShowingOutfitBuilder) {
                OutfitBuilderView()
            }
                .padding(.bottom, 8) 

        }
    }
}

#Preview {
    WardrobeView()
}
