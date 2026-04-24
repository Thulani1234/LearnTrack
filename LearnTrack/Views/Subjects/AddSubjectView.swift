//
//  AddSubjectView.swift
//  LearnTrack
//
//  Created by COBSCCOMP242P-028 on 2026-04-24.
//

import SwiftUI

struct AddSubjectView: View {
    @EnvironmentObject var router: AppRouter
    @State private var name = ""
    @State private var targetScore = "100"
    
    var body: some View {
        Form {
            Section(header: Text("Subject Details")) {
                TextField("Subject Name", text: $name)
                TextField("Target Score", text: $targetScore)
                    .keyboardType(.numberPad)
            }
            
            Section {
                PrimaryButton(title: "Save Subject") {
                    router.navigateBack()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationTitle("Add Subject")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { router.navigateBack() }) {
                    Label("Back", systemImage: "chevron.left")
                }
            }
        }
    }
}

