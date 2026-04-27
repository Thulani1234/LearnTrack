import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var name = "Sara"
    @State private var email = "sara@example.com"
    @State private var selectedGrade = "Grade 11"
    @State private var selectedSubjects: Set<String> = ["Maths", "Science", "ICT"]
    
    // Image & File Selection State
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var showingFilePicker = false
    @State private var uploadedDocuments: [String] = []
    
    let grades = ["Grade 10", "Grade 11", "Grade 12", "University", "Self-learner"]
    
    let subjectsByCategory: [String: [String]] = [
        "Grade 10": ["Maths", "Science", "English", "ICT", "History", "Commerce", "Geography"],
        "Grade 11": ["Maths", "Science", "English", "ICT", "History", "Commerce", "Literature"],
        "Grade 12": ["Combined Maths", "Physics", "Chemistry", "Biology", "Economics", "Accounting", "ICT"],
        "University": ["Computer Science", "Engineering", "Medicine", "Business", "Law", "Arts", "Psychology"],
        "Self-learner": ["Programming", "Design", "Marketing", "Photography", "Music", "Cooking", "Fitness"]
    ]
    
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
                Text("Edit Profile")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button(action: { router.navigateBack() }) {
                    Text("Save")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Full Clickable Avatar Area
                    Menu {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Photo Library", systemImage: "photo.on.rectangle")
                        }
                        
                        Button(action: { showingFilePicker = true }) {
                            Label("Browse Files", systemImage: "folder")
                        }
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                            } else {
                                Circle()
                                    .fill(LinearGradient(colors: [AppColors.primary.opacity(0.8), AppColors.secondary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 110, height: 110)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Text(name.prefix(1).uppercased())
                                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                            Text("EDIT")
                                                .font(.system(size: 10, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                    )
                            }
                            
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                )
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .offset(x: 5, y: 5)
                        }
                    }
                    .padding(.top, 10)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 28) {
                        // Personal Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PERSONAL INFORMATION")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            CustomEditField(title: "Full Name", text: $name)
                            CustomEditField(title: "Email Address", text: $email, keyboardType: .emailAddress)
                        }
                        
                        // Study Category
                        VStack(alignment: .leading, spacing: 16) {
                            Text("STUDY CATEGORY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(grades, id: \.self) { grade in
                                        Button(action: { 
                                            selectedGrade = grade 
                                            // Reset subjects when category changes or keep common ones? 
                                            // User requested "according to study category"
                                        }) {
                                            Text(grade)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedGrade == grade ? .white : AppColors.textPrimary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(selectedGrade == grade ? AppColors.primary : AppColors.cardBackground)
                                                .cornerRadius(20)
                                                .shadow(color: selectedGrade == grade ? AppColors.primary.opacity(0.2) : Color.clear, radius: 5, x: 0, y: 3)
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // Subjects Selection (Checkboxes)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SELECT SUBJECTS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            VStack(spacing: 0) {
                                let availableSubjects = subjectsByCategory[selectedGrade] ?? []
                                ForEach(availableSubjects, id: \.self) { subject in
                                    Button(action: {
                                        if selectedSubjects.contains(subject) {
                                            selectedSubjects.remove(subject)
                                        } else {
                                            selectedSubjects.insert(subject)
                                        }
                                    }) {
                                        HStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(selectedSubjects.contains(subject) ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                                                    .frame(width: 22, height: 22)
                                                
                                                if selectedSubjects.contains(subject) {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(AppColors.primary)
                                                        .frame(width: 22, height: 22)
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            Text(subject)
                                                .font(AppTypography.body)
                                                .foregroundColor(AppColors.textPrimary)
                                                .padding(.leading, 8)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                    }
                                    
                                    if subject != availableSubjects.last {
                                        Divider().padding(.leading, 50)
                                    }
                                }
                            }
                            .background(AppColors.cardBackground)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                        }
                        // MY DOCUMENTS Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("MY DOCUMENTS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                                Spacer()
                                
                                Menu {
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        Label("Photo Library", systemImage: "photo.on.rectangle")
                                    }
                                    
                                    Button(action: { showingFilePicker = true }) {
                                        Label("Browse Files", systemImage: "folder")
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Media")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(uploadedDocuments, id: \.self) { doc in
                                        HStack(spacing: 10) {
                                            Image(systemName: "doc.fill")
                                                .foregroundColor(AppColors.primary)
                                            Text(doc)
                                                .font(.system(size: 14, weight: .medium))
                                            Button(action: {
                                                uploadedDocuments.removeAll(where: { $0 == doc })
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red.opacity(0.6))
                                            }
                                        }
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.02), radius: 5)
                                    }
                                    
                                    if uploadedDocuments.isEmpty {
                                        Text("No documents yet.")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                                            .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    // If it's an image, we could update profile photo, 
                    // but for now let's assume this button adds to documents.
                    uploadedDocuments.append(url.lastPathComponent)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct CustomEditField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .font(AppTypography.body)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
    }
}
