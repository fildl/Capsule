//
//  StatsView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct StatsView: View {
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ContentUnavailableView(
                    "Stats Coming Soon",
                    systemImage: "chart.bar",
                    description: Text("Track your wardrobe usage here.")
                )
                .padding(.top, 100)
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
        .tint(.primary)
    }
}

#Preview {
    StatsView()
}
