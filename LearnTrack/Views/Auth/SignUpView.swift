import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var country = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var showOTPVerification = false
    
    private let authService = AuthenticationService.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Join LearnTrack and start tracking your academic success today.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(icon: "person.fill", placeholder: "Name", text: $name)
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email, disableAutocapitalization: true)
                    CustomTextField(icon: "phone.fill", placeholder: "Phone Number", text: $phoneNumber)
                    CustomTextField(icon: "house.fill", placeholder: "Address", text: $address)
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
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    CustomTextField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                }
                .padding(.top, 10)
                
                
                // Terms & Conditions
                Toggle(isOn: $agreedToTerms) {
                    HStack(spacing: 4) {
                        Text("I agree to the")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Terms of Service")
                            .font(AppTypography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        Text("&")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Privacy Policy")
                            .font(AppTypography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.top, 10)
                
                // Sign Up Button
                Button(action: {
                    signUp()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading || !agreedToTerms || name.isEmpty || email.isEmpty || phoneNumber.isEmpty || address.isEmpty || country.isEmpty || password.isEmpty || password != confirmPassword)
                .padding(.top, 10)
                
                Spacer()
                
                // Footer
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("Already have an account?")
                            .font(AppTypography.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Sign In")
                            .font(AppTypography.bodySmall)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.textPrimary)
                        .fontWeight(.bold)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    
    private func signUp() {
        // Validate form
        guard !name.isEmpty else {
            showError = true
            errorMessage = "Please enter your name"
            return
        }
        
        guard !email.isEmpty else {
            showError = true
            errorMessage = "Please enter your email"
            return
        }
        
        guard !phoneNumber.isEmpty else {
            showError = true
            errorMessage = "Please enter your phone number"
            return
        }
        
        guard !password.isEmpty else {
            showError = true
            errorMessage = "Please enter your password"
            return
        }
        
        guard password == confirmPassword else {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        guard agreedToTerms else {
            showError = true
            errorMessage = "Please agree to the terms and conditions"
            return
        }
        
        isLoading = true
        showError = false
        errorMessage = ""
        
        // Register user
        let result = authService.registerUser(name: name, email: email, phoneNumber: phoneNumber, password: password, address: address, country: country)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            if let user = result.user {
                print("User Registered Successfully:")
                print("Name: \(user.name)")
                print("Email: \(user.email)")
                print("Phone: \(user.phoneNumber)")
                
                // Set current user in app state
                appState.currentUser = user
                
                // Navigate to main app directly (no OTP)
                withAnimation {
                    appState.isLoggedIn = true
                }
                dismiss()
            } else if let error = result.error {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SubjectCheckboxRow: View {
    let subject: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                    .font(.system(size: 18))
                
                Text(subject)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? AppColors.primary : AppColors.textSecondary)
                    .font(.system(size: 20))
                
                configuration.label
            }
        }
    }
}
