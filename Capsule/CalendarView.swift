//
//  CalendarView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Calendar Coming Soon",
                systemImage: "calendar",
                description: Text("Plan your outfits here.")
            )
            .navigationTitle("Calendar")
        }
    }
}

#Preview {
    CalendarView()
}
