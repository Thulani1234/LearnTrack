//
//  VoiceDataTestView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct VoiceDataTestView: View {
    @State private var isSeeding = false
    @State private var seedMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Voice Data Seeder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    // Seed All Voice Data
                    Button(action: {
                        seedAllVoiceData()
                    }) {
                        HStack {
                            if isSeeding {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                            }
                            
                            Text("Seed All Voice Data")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isSeeding)
                    
                    // Clear Voice Data
                    Button(action: {
                        clearVoiceData()
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 16))
                            
                            Text("Clear Voice Data")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Regenerate Voice Data
                    Button(action: {
                        regenerateVoiceData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 16))
                            
                            Text("Regenerate Voice Data")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                
                // Status Message
                if !seedMessage.isEmpty {
                    Text(seedMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .navigationTitle("Voice Data Test")
            .padding()
        }
        .alert("Voice Data Operation", isPresented: $showingAlert) {
            Button("OK") {
                showingAlert = false
            }
        } message: {
            Text(seedMessage)
        }
    }
    
    private func seedAllVoiceData() {
        isSeeding = true
        seedMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            DataMigrationService.shared.seedVoiceDataOnly()
            seedMessage = "✅ Voice data seeded successfully! 15 sample recordings created across all subjects."
            isSeeding = false
        }
    }
    
    private func clearVoiceData() {
        DataMigrationService.shared.clearVoiceDataOnly()
        seedMessage = "🗑️ Voice data cleared successfully!"
        showingAlert = true
    }
    
    private func regenerateVoiceData() {
        isSeeding = true
        seedMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            DataMigrationService.shared.regenerateVoiceData()
            seedMessage = "🔄 Voice data regenerated successfully! Fresh sample recordings created."
            isSeeding = false
        }
    }
}

#Preview {
    VoiceDataTestView()
}
