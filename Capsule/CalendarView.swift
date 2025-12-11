//
//  CalendarView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ContentUnavailableView(
                    "Calendar Coming Soon",
                    systemImage: "calendar",
                    description: Text("Plan your outfits here.")
                )
                .padding(.top, 100) // Visual balance since it's now scrolling
            }
            .navigationTitle("Calendar")
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
    CalendarView()
}
