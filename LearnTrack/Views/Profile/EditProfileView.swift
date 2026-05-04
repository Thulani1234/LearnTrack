import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var name = "Sara"
    @State private var email = "sara@example.com"
    @State private var phoneNumber = "+1 234 567 890"
    @State private var selectedSubjects: Set<String> = ["Maths", "Science", "ICT"]
    
    // Image & File Selection State
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
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
                    // Full Clickable Avatar Area (PhotosPicker as primary action)
                    ZStack(alignment: .topTrailing) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                // Animated Outer Glow
                                Circle()
                                    .fill(AppColors.primary.opacity(0.15))
                                    .frame(width: 140, height: 140)
                                    .scaleEffect(1.1)
                                    .blur(radius: 20)
                                
                                ZStack(alignment: .bottomTrailing) {
                                    if let profileImage {
                                        profileImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                            .shadow(color: Color.black.opacity(0.15), radius: 15)
                                    } else {
                                        Circle()
                                            .fill(LinearGradient(colors: [AppColors.primary, AppColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                VStack(spacing: 4) {
                                                    Text(name.prefix(1).uppercased())
                                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                                    Text("TAP TO EDIT")
                                                        .font(.system(size: 8, weight: .bold))
                                                        .tracking(1)
                                                }
                                                .foregroundColor(.white)
                                            )
                                            .shadow(color: AppColors.primary.opacity(0.3), radius: 15)
                                    }
                                    
                                    // Glassmorphic Camera Button
                                    ZStack {
                                        BlurView(style: .systemThinMaterial)
                                            .frame(width: 38, height: 38)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                                        
                                        Circle()
                                            .fill(AppColors.primary)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .offset(x: 4, y: 4)
                                }
                            }
                        }
                        
                        // Separate Remove Button (Only if photo exists)
                        if profileImage != nil {
                            Button(action: {
                                withAnimation {
                                    profileImage = nil
                                    appState.currentAlert = AppAlert(title: "Photo Removed", message: "Your profile picture has been reset.", icon: "person.crop.circle.badge.minus", color: .red, type: .success)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.red).shadow(radius: 5))
                            }
                            .offset(x: 10, y: -10)
                        }
                    }
                    .padding(.top, 20)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        withAnimation(.spring()) {
                                            profileImage = Image(uiImage: uiImage)
                                            appState.currentAlert = AppAlert(title: "Looking Great! ✨", message: "Your profile photo has been updated successfully.", icon: "sparkles", color: AppColors.primary, type: .success)
                                        }
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
                            CustomEditField(title: "Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
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
