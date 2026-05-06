import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditProfileView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var country = ""
    @State private var selectedSubjects: Set<String> = ["Maths", "Science", "ICT"]
    @State private var didLoadUser = false
    
    // Image & File Selection State
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?

    private let authService = AuthenticationService.shared
    
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
                Button(action: { saveProfile() }) {
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
                            CustomEditField(title: "Address", text: $address)
                            Picker(selection: $country) {
                                Text("Select Country").tag("")
                                Text("Afghanistan").tag("Afghanistan")
                                Text("Albania").tag("Albania")
                                Text("Algeria").tag("Algeria")
                                Text("Argentina").tag("Argentina")
                                Text("Australia").tag("Australia")
                                Text("Austria").tag("Austria")
                                Text("Bangladesh").tag("Bangladesh")
                                Text("Belgium").tag("Belgium")
                                Text("Brazil").tag("Brazil")
                                Text("Bulgaria").tag("Bulgaria")
                                Text("Canada").tag("Canada")
                                Text("Chile").tag("Chile")
                                Text("China").tag("China")
                                Text("Colombia").tag("Colombia")
                                Text("Croatia").tag("Croatia")
                                Text("Czech Republic").tag("Czech Republic")
                                Text("Denmark").tag("Denmark")
                                Text("Egypt").tag("Egypt")
                                Text("Finland").tag("Finland")
                                Text("France").tag("France")
                                Text("Germany").tag("Germany")
                                Text("Greece").tag("Greece")
                                Text("Hungary").tag("Hungary")
                                Text("Iceland").tag("Iceland")
                                Text("India").tag("India")
                                Text("Indonesia").tag("Indonesia")
                                Text("Ireland").tag("Ireland")
                                Text("Israel").tag("Israel")
                                Text("Italy").tag("Italy")
                                Text("Japan").tag("Japan")
                                Text("Jordan").tag("Jordan")
                                Text("Kenya").tag("Kenya")
                                Text("South Korea").tag("South Korea")
                                Text("Lebanon").tag("Lebanon")
                                Text("Malaysia").tag("Malaysia")
                                Text("Mexico").tag("Mexico")
                                Text("Morocco").tag("Morocco")
                                Text("Netherlands").tag("Netherlands")
                                Text("New Zealand").tag("New Zealand")
                                Text("Norway").tag("Norway")
                                Text("Pakistan").tag("Pakistan")
                                Text("Peru").tag("Peru")
                                Text("Philippines").tag("Philippines")
                                Text("Poland").tag("Poland")
                                Text("Portugal").tag("Portugal")
                                Text("Romania").tag("Romania")
                                Text("Russia").tag("Russia")
                                Text("Saudi Arabia").tag("Saudi Arabia")
                                Text("Singapore").tag("Singapore")
                                Text("South Africa").tag("South Africa")
                                Text("Spain").tag("Spain")
                                Text("Sweden").tag("Sweden")
                                Text("Switzerland").tag("Switzerland")
                                Text("Thailand").tag("Thailand")
                                Text("Turkey").tag("Turkey")
                                Text("Ukraine").tag("Ukraine")
                                Text("United Arab Emirates").tag("United Arab Emirates")
                                Text("United Kingdom").tag("United Kingdom")
                                Text("United States").tag("United States")
                                Text("Vietnam").tag("Vietnam")
                                Text("Other").tag("Other")
                            } label: {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(country.isEmpty ? "Country" : country)
                                        .foregroundColor(country.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(16)
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
        .onAppear {
            loadFromCurrentUserIfNeeded()
        }
    }

    private func loadFromCurrentUserIfNeeded() {
        guard !didLoadUser else { return }
        didLoadUser = true

        guard let user = appState.currentUser else { return }
        name = user.name
        email = user.email
        phoneNumber = user.phoneNumber
        address = user.address
        country = user.country
    }

    private func saveProfile() {
        guard var user = appState.currentUser else {
            router.navigateBack()
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCountry = country.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            appState.currentAlert = AppAlert(
                title: "Missing name",
                message: "Please enter your name.",
                icon: "person.fill.xmark",
                color: .red,
                type: .warning
            )
            return
        }

        let success = authService.updateUserProfile(
            userId: user.id,
            name: trimmedName,
            email: trimmedEmail.isEmpty ? nil : trimmedEmail,
            phoneNumber: trimmedPhone.isEmpty ? nil : trimmedPhone,
            address: trimmedAddress.isEmpty ? nil : trimmedAddress,
            country: trimmedCountry.isEmpty ? nil : trimmedCountry,
            profileImageURL: nil
        )

        if success {
            user.name = trimmedName
            if !trimmedEmail.isEmpty { user.email = trimmedEmail }
            if !trimmedPhone.isEmpty { user.phoneNumber = trimmedPhone }
            if !trimmedAddress.isEmpty { user.address = trimmedAddress }
            if !trimmedCountry.isEmpty { user.country = trimmedCountry }
            user.updatedAt = Date()
            appState.currentUser = user

            appState.currentAlert = AppAlert(
                title: "Profile updated",
                message: "Your changes were saved.",
                icon: "checkmark.circle.fill",
                color: AppColors.primary,
                type: .success
            )
            router.navigateBack()
        } else {
            appState.currentAlert = AppAlert(
                title: "Save failed",
                message: "Could not update your profile. Please try again.",
                icon: "xmark.octagon.fill",
                color: .red,
                type: .warning
            )
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
