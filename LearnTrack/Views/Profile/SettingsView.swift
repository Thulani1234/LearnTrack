//
//  SettingsView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useFaceID") private var useFaceID = true
    @AppStorage("pushNotifications") private var pushNotifications = true
    
    var body: some View {
        Form {
            Section(header: Text("Security")) {
                Toggle("Require Face ID / Touch ID", isOn: $useFaceID)
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Push Notifications", isOn: $pushNotifications)
                    .onChange(of: pushNotifications) { newValue in
                        if newValue {
                            NotificationManager.shared.requestPermission()
                        }
                    }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
