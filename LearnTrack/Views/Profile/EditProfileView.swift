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
    @State private var selectedProfileImageURL: String?

    private let authService = AuthenticationService.shared

    var body: some View {
        VStack(spacing: 0) {
            header

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
                                    if let profileImage = profileImage {
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
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 48, weight: .black))
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
                                    selectedProfileImageURL = nil
                                    if var currentUser = appState.currentUser {
                                        currentUser.profileImageURL = nil
                                        appState.currentUser = currentUser
                                    }
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
                                if let uiImage = UIImage(data: data), let savedPath = saveProfileImage(uiImage) {
                                    await MainActor.run {
                                        withAnimation(.spring()) {
                                            profileImage = Image(uiImage: uiImage)
                                            selectedProfileImageURL = savedPath
                                            appState.currentAlert = AppAlert(title: "Looking Great! ", message: "Your profile photo has been updated successfully.", icon: "sparkles", color: AppColors.primary, type: .success)
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
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Country")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)

                                Menu {
                                    Button("Afghanistan")   { country = "Afghanistan" }
                                    Button("Albania")       { country = "Albania" }
                                    Button("Algeria")       { country = "Algeria" }
                                    Button("Argentina")     { country = "Argentina" }
                                    Button("Australia")     { country = "Australia" }
                                    Button("Austria")       { country = "Austria" }
                                    Button("Bangladesh")    { country = "Bangladesh" }
                                    Button("Belgium")       { country = "Belgium" }
                                    Button("Brazil")        { country = "Brazil" }
                                    Button("Bulgaria")      { country = "Bulgaria" }
                                    Button("Canada")        { country = "Canada" }
                                    Button("Chile")         { country = "Chile" }
                                    Button("China")         { country = "China" }
                                    Button("Colombia")      { country = "Colombia" }
                                    Button("Croatia")       { country = "Croatia" }
                                    Button("Czech Republic"){ country = "Czech Republic" }
                                    Button("Denmark")       { country = "Denmark" }
                                    Button("Egypt")         { country = "Egypt" }
                                    Button("Finland")       { country = "Finland" }
                                    Button("France")        { country = "France" }
                                    Button("Germany")       { country = "Germany" }
                                    Button("Greece")        { country = "Greece" }
                                    Button("Hungary")       { country = "Hungary" }
                                    Button("Iceland")       { country = "Iceland" }
                                    Button("India")         { country = "India" }
                                    Button("Indonesia")     { country = "Indonesia" }
                                    Button("Ireland")       { country = "Ireland" }
                                    Button("Israel")        { country = "Israel" }
                                    Button("Italy")         { country = "Italy" }
                                    Button("Japan")         { country = "Japan" }
                                    Button("Jordan")        { country = "Jordan" }
                                    Button("Kenya")         { country = "Kenya" }
                                    Button("South Korea")   { country = "South Korea" }
                                    Button("Lebanon")       { country = "Lebanon" }
                                    Button("Malaysia")      { country = "Malaysia" }
                                    Button("Mexico")        { country = "Mexico" }
                                    Button("Morocco")       { country = "Morocco" }
                                    Button("Netherlands")   { country = "Netherlands" }
                                    Button("New Zealand")   { country = "New Zealand" }
                                    Button("Norway")        { country = "Norway" }
                                    Button("Pakistan")      { country = "Pakistan" }
                                    Button("Peru")          { country = "Peru" }
                                    Button("Philippines")   { country = "Philippines" }
                                    Button("Poland")        { country = "Poland" }
                                    Button("Portugal")      { country = "Portugal" }
                                    Button("Romania")       { country = "Romania" }
                                    Button("Russia")        { country = "Russia" }
                                    Button("Saudi Arabia")  { country = "Saudi Arabia" }
                                    Button("Singapore")     { country = "Singapore" }
                                    Button("South Africa")  { country = "South Africa" }
                                    Button("Spain")         { country = "Spain" }
                                    Button("Sri Lanka")     { country = "Sri Lanka" }
                                    Button("Sweden")        { country = "Sweden" }
                                    Button("Switzerland")   { country = "Switzerland" }
                                    Button("Thailand")      { country = "Thailand" }
                                    Button("Turkey")        { country = "Turkey" }
                                    Button("Ukraine")       { country = "Ukraine" }
                                    Button("United Arab Emirates") { country = "United Arab Emirates" }
                                    Button("United Kingdom"){ country = "United Kingdom" }
                                    Button("United States") { country = "United States" }
                                    Button("Vietnam")       { country = "Vietnam" }
                                    Button("Other")         { country = "Other" }
                                } label: {
                                    HStack {
                                        Text(country.isEmpty ? "Select Country" : country)
                                            .font(AppTypography.body)
                                            .foregroundColor(country.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                                }
                                .accessibilityLabel("Country picker")
                                .accessibilityHint("Select your country")
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

    private var header: some View {
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
    }

    private func saveProfileImage(_ uiImage: UIImage) -> String? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            return nil
        }

        let filename = "profile-photo-\(UUID().uuidString.prefix(8)).jpg"
        let fileURL = documents.appendingPathComponent(filename)

        do {
            try imageData.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            print("Failed to save profile image: \(error)")
            return nil
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
        selectedProfileImageURL = user.profileImageURL
        if let imagePath = user.profileImageURL,
           let uiImage = UIImage(contentsOfFile: imagePath) {
            profileImage = Image(uiImage: uiImage)
        }
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
            profileImageURL: selectedProfileImageURL,
            clearProfileImage: selectedProfileImageURL == nil
        )

        if success {
            user.name = trimmedName
            if !trimmedEmail.isEmpty { user.email = trimmedEmail }
            if !trimmedPhone.isEmpty { user.phoneNumber = trimmedPhone }
            if !trimmedAddress.isEmpty { user.address = trimmedAddress }
            if !trimmedCountry.isEmpty { user.country = trimmedCountry }
            user.profileImageURL = selectedProfileImageURL
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
