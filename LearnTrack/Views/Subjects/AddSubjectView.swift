import SwiftUI
import PhotosUI

struct AddSubjectView: View {
    @EnvironmentObject var data: MockData
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var targetScore = "85"
    @State private var currentMarks = ""
    @State private var selectedCategory = "Exam"
    @State private var selectedIcon = "book.fill"
    @State private var selectedColor = AppColors.primary
    
    // Image State
    @State private var selectedItem: PhotosPickerItem?
    @State private var subjectImage: Image?
    
    let categories = ["Exam", "Project", "Assignment"]
    let icons = ["book.fill", "function", "flask.fill", "laptopcomputer", "pencil.tip", "globe.americas.fill", "music.note", "sportscourt.fill"]
    let colors: [Color] = [.blue, .purple, .orange, .pink, .green, .red, .cyan, .indigo]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.textPrimary)
                        .font(.headline)
                        .padding(12)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
                Spacer()
                Text("New Subject")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Full Clickable Preview Area
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            ZStack {
                                if let subjectImage {
                                    subjectImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: 32))
                                        .overlay(RoundedRectangle(cornerRadius: 32).stroke(selectedColor.opacity(0.3), lineWidth: 2))
                                } else {
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(selectedColor.opacity(0.1))
                                        .frame(width: 130, height: 130)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: selectedIcon)
                                            .font(.system(size: 40))
                                        Text("Tap to Browse")
                                            .font(.system(size: 10, weight: .bold))
                                            .opacity(0.5)
                                    }
                                    .foregroundColor(selectedColor)
                                }
                            }
                            
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .offset(x: 8, y: 8)
                        }
                    }
                    .padding(.top, 10)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        withAnimation(.spring()) {
                                            subjectImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Name Input
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUBJECT NAME")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            TextField("e.g. Advanced Physics", text: $name)
                                .font(AppTypography.body)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CATEGORY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        Text(cat)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(selectedCategory == cat ? .white : AppColors.textSecondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedCategory == cat ? selectedColor : AppColors.cardBackground)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        // Marks & Target
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("MARKS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                
                                TextField("0", text: $currentMarks)
                                    .keyboardType(.numberPad)
                                    .font(AppTypography.body)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(16)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("TARGET SCORE (%)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                
                                HStack {
                                    TextField("85", text: $targetScore)
                                        .keyboardType(.numberPad)
                                        .font(AppTypography.body)
                                    Text("%")
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("THEME COLOR")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(colors, id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 3)
                                                    .opacity(selectedColor == color ? 1 : 0)
                                            )
                                            .onTapGesture {
                                                selectedColor = color
                                            }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUBJECT ICON")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(icons, id: \.self) { icon in
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? selectedColor.opacity(0.1) : AppColors.cardBackground)
                                                .frame(width: 50, height: 50)
                                            Image(systemName: icon)
                                                .foregroundColor(selectedIcon == icon ? selectedColor : AppColors.textSecondary)
                                        }
                                        .onTapGesture {
                                            selectedIcon = icon
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        let marksValue = Int(currentMarks) ?? 0
                        let newSubject = Subject(
                            name: name.isEmpty ? "New Subject" : name,
                            colorHex: selectedColor.toHex() ?? "6366F1",
                            progress: Double(marksValue) / 100.0,
                            targetScore: Int(targetScore) ?? 85,
                            currentScore: marksValue,
                            icon: selectedIcon
                        )
                        data.subjects.append(newSubject)
                        
                        withAnimation {
                            appState.currentAlert = AppAlert(
                                title: "Subject Added! ✨",
                                message: "\(newSubject.name) has been added to your curriculum.",
                                icon: newSubject.icon,
                                color: selectedColor,
                                type: .success
                            )
                        }
                        
                        router.navigateBack()
                    }) {
                        Text("Create Subject")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedColor)
                            .cornerRadius(20)
                            .shadow(color: selectedColor.opacity(0.3), radius: 15, x: 0, y: 10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }

        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: currentMarks) { newValue in
            if let marks = Int(newValue) {
                // Set target to be slightly higher (e.g., +5%) to ensure they aren't the same
                let target = min(marks + 5, 100)
                targetScore = "\(target)"
            }
        }
    }
}
