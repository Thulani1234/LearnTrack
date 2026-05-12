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
    
    private let authService = AuthenticationService.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Header / Profile Section
                VStack(spacing: 20) {
                    ZStack {
                        if let imagePath = appState.currentUser?.profileImageURL,
                           let uiImage = UIImage(contentsOfFile: imagePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                        } else {
                            Circle()
                                .fill(LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    
                    VStack(spacing: 6) {
                        Text("\(appState.currentUser?.name ?? "User") ")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Student")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Profile")
                    .accessibilityValue(appState.currentUser?.name ?? "User")
                }
                .padding(.top, 40)
                
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
                        .accessibilityLabel("Edit profile")
                        .accessibilityHint("Edit your profile information")
                        .accessibilityAddTraits(.isButton)
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "bell.fill", title: "Notifications", color: .red) {
                            router.navigate(to: .notifications)
                        }
                        .accessibilityLabel("Notifications")
                        .accessibilityHint("Manage your notification settings")
                        .accessibilityAddTraits(.isButton)
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "lock.fill", title: "Privacy & Security", color: .green) {
                            router.navigate(to: .privacy)
                        }
                        .accessibilityLabel("Privacy and security")
                        .accessibilityHint("Manage your privacy and security settings")
                        .accessibilityAddTraits(.isButton)
                        Divider().padding(.leading, 60)
                        ProfileOptionItem(icon: "gearshape.fill", title: "Settings", color: .gray) {
                            router.navigate(to: .settings)
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Open app settings")
                        .accessibilityAddTraits(.isButton)
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
                        ProfileOptionItem(icon: "questionmark.circle.fill", title: "Help Center", color: .indigo) {
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
                

                
                // Logout
                Button(action: {
                    withAnimation {
                        appState.isLoggedIn = false
                        appState.currentUser = nil
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

