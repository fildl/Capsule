//
//  StatsView.swift
//  Capsule
//
//  Created by Capsule Assistant on 05/12/25.
//

import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Stats Coming Soon",
                systemImage: "chart.bar",
                description: Text("Track your wardrobe usage here.")
            )
            .navigationTitle("Statistics")
        }
    }
}

#Preview {
    StatsView()
}
