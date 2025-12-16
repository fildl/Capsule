//
//  SettingsView.swift
//  Capsule
//
//  Created by Capsule Assistant on 10/12/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("App") {
                    NavigationLink(destination: GeneralSettingsView()) {
                        Label("General", systemImage: "gear")
                    }
                    
                    NavigationLink(destination: ArchivedItemsView()) {
                        Label("Archive", systemImage: "archivebox")
                    }
                    
                    NavigationLink(destination: TagManagementView()) {
                        Label("Manage Tags", systemImage: "tag")
                    }
                    
                    NavigationLink(destination: DataSettingsView()) {
                        Label("Data Management", systemImage: "externaldrive")
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "C"
    
    var body: some View {
        Form {
            Section(header: Text("Units")) {
                Picker("Temperature", selection: $temperatureUnit) {
                    Text("Celsius (°C)").tag("C")
                    Text("US (Descriptive)").tag("F")
                }
            }
        }
        .navigationTitle("General")
    }
}

struct DataSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Backup & Restore"), footer: Text("Export your wardrobe data to a file or restore from a previous backup.")) {
                Button("Export Data") {
                    // Action
                }
                .disabled(true)
                .foregroundStyle(.secondary)
                
                Button("Import Data") {
                    // Action
                }
                .disabled(true)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Data Management")
    }
}

#Preview {
    SettingsView()
}
