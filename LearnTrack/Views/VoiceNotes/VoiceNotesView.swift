//
//  VoiceNotesView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

/*import SwiftUI

struct VoiceNotesView: View {
    @State private var isRecording = false
    @State private var recordings = ["Lecture 1 Summary", "Math Formulas"]
    
    var body: some View {
        VStack {
            List {
                ForEach(recordings, id: \\.self) { recording in
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(AppColors.primary)
                        Text(recording)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "play.circle")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(AppColors.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            
            Spacer()
            
            Button(action: {
                isRecording.toggle()
                if !isRecording {
                    recordings.append("New Recording \\(recordings.count + 1)")
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isRecording ? AppColors.error.opacity(0.3) : AppColors.primary.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(isRecording ? AppColors.error : AppColors.primary)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Voice Notes")
    }
}
*/
import SwiftUI

struct VoiceNotesView: View {
    @State private var isRecording = false
    @State private var recordings = ["Lecture 1 Summary", "Math Formulas"]
    
    var body: some View {
        VStack {
            List {
                ForEach(recordings, id: \.self) { recording in
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(AppColors.primary)
                        
                        Text(recording)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "play.circle")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(AppColors.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            
            Spacer()
            
            Button(action: {
                isRecording.toggle()
                
                // When stopping recording → save it
                if !isRecording {
                    recordings.append("New Recording \(recordings.count + 1)")
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isRecording ? AppColors.error.opacity(0.3) : AppColors.primary.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(isRecording ? AppColors.error : AppColors.primary)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Voice Notes")
    }
}
