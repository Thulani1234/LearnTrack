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
    
    private var phoneDigits: String {
        phoneNumber.filter { $0.isNumber }
    }
    
    private var isPhoneValid: Bool {
        phoneDigits.count == 10 && phoneDigits.count == phoneNumber.count
    }
    
    private var phoneValidationMessage: String? {
        guard !phoneNumber.isEmpty else { return nil }
        if phoneDigits.count != phoneNumber.count {
            return "Phone number must contain only digits"
        }
        if phoneDigits.count != 10 {
            return "Phone number must be exactly 10 digits"
        }
        return nil
    }
    
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
                        .accessibilityLabel("Full name")
                        .accessibilityHint("Enter your full name")
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email, disableAutocapitalization: true)
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Enter your email address")
                    CustomTextField(icon: "phone.fill", placeholder: "Phone Number", text: $phoneNumber)
                        .accessibilityLabel("Phone number")
                        .accessibilityHint("Enter your phone number")
                    if let phoneValidationMessage {
                        Text(phoneValidationMessage)
                            .font(AppTypography.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    CustomTextField(icon: "house.fill", placeholder: "Address", text: $address)
                        .accessibilityLabel("Address")
                        .accessibilityHint("Enter your address")
                    Menu {
                        Button("Select Country") { country = "" }
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
                        HStack(spacing: 15) {
                            Image(systemName: "globe")
                                .foregroundColor(AppColors.primary.opacity(0.7))
                                .frame(width: 20)
                            Text(country.isEmpty ? "Country" : country)
                                .foregroundColor(country.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Country picker")
                    .accessibilityHint("Select your country")
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        .accessibilityLabel("Password")
                        .accessibilityHint("Enter your password")
                    CustomTextField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        .accessibilityLabel("Confirm password")
                        .accessibilityHint("Re-enter your password to confirm")
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
                .accessibilityLabel("Terms and conditions")
                .accessibilityHint("Agree to terms and privacy policy")
                .accessibilityAddTraits(.isButton)
                .padding(.top, 10)
                
                // Sign Up Button
                Button(action: {
                    signUp()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .accessibilityLabel("Loading")
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
                .disabled(isLoading
                          || !agreedToTerms
                          || name.isEmpty
                          || email.isEmpty
                          || phoneNumber.filter({ $0.isNumber }).count != 10
                          || phoneNumber.count != 10
                          || address.isEmpty
                          || country.isEmpty
                          || password.isEmpty
                          || password != confirmPassword)
                .accessibilityLabel("Create account button")
                .accessibilityHint("Tap to create your account")
                .accessibilityAddTraits(.isButton)
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
                .accessibilityLabel("Sign in")
                .accessibilityHint("Go to sign in screen")
                .accessibilityAddTraits(.isButton)
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
                .accessibilityLabel("Go back")
                .accessibilityHint("Return to previous screen")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $appState.showLoginAfterSignup) {
            LoginView()
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
        
        let digitsOnlyPhone = phoneNumber.filter { $0.isNumber }
        guard digitsOnlyPhone.count == 10 && digitsOnlyPhone.count == phoneNumber.count else {
            showError = true
            errorMessage = "Phone number must be exactly 10 digits"
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
                
                // Navigate to login - flag will trigger onChange in WelcomeView
                appState.showLoginAfterSignup = true
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
