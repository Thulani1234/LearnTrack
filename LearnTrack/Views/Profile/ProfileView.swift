import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    
    @State private var showingFilePicker = false
    @State private var myDocuments: [String] = ["Study_Plan_2026.pdf", "Certificate_Maths.pdf"]
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Header / Profile Section
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 120, height: 120)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                        
                        Text("S")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 6) {
                        Text("Sara 👋")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Grade 11 Student")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 40)
                
                // Achievement Stats
                HStack(spacing: 16) {
                    AchievementCard(icon: "flame.fill", value: "7", title: "Streak", color: .orange)
                    AchievementCard(icon: "timer", value: "45h", title: "Study", color: .purple)
                }
                .padding(.horizontal)
                
                // Account Settings
                VStack(alignment: .leading, spacing: 20) {
                    Text("ACCOUNT SETTINGS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ProfileOptionItem(icon: "person.fill", title: "Edit Profile", color: .blue) {
                            router.navigate(to: .editProfile)
                        }
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "bell.fill", title: "Notifications", color: .red) {
                            router.navigate(to: .notifications)
                        }
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "lock.fill", title: "Privacy & Security", color: .green) {
                            router.navigate(to: .privacy)
                        }
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "gearshape.fill", title: "Settings", color: .gray) {
                            router.navigate(to: .settings)
                        }
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                }
                
                // Support
                VStack(alignment: .leading, spacing: 20) {
                    Text("SUPPORT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ProfileOptionItem(icon: "questionmark.circle.fill", title: "Help Center", color: .purple) {
                            router.navigate(to: .help)
                        }
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "envelope.fill", title: "Contact Us", color: .orange) {
                            router.navigate(to: .contact)
                        }
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                }
                
                // My Documents Section
                VStack(alignment: .leading, spacing: 20) {
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
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Document Files
                            ForEach(myDocuments, id: \.self) { doc in
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(AppColors.primary)
                                    Text(doc)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
                            }
                            
                            // Selected Images from Gallery
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 44)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary.opacity(0.1), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                
                // Logout
                Button(action: {
                    withAnimation {
                        appState.isLoggedIn = false
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(18)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            withAnimation {
                                profileImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    myDocuments.append(url.lastPathComponent)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct AchievementCard: View {
    var icon: String
    var value: String
    var title: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct ProfileOptionItem: View {
    var icon: String
    var title: String
    var color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .cornerRadius(10)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.3))
            }
            .padding()
        }
    }
}

