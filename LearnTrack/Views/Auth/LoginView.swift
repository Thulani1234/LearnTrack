import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showResetPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    private let authService = AuthenticationService.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Background Decorative Elements
            VStack {
                Circle()
                    .fill(LinearGradient(colors: [AppColors.primary.opacity(0.1), AppColors.secondary.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 400, height: 400)
                    .offset(x: 100, y: -200)
                Spacer()
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Welcome
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                        .padding()
                        .background(AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: AppColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Sign in to continue your learning journey")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Input Fields
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email Address", text: $email, disableAutocapitalization: true)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    
                    Button(action: {
                        showResetPassword = true
                    }) {
                        Text("Reset Password")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.top, 20)
                
                // Login Button
                Button(action: {
                    login()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                    Text("OR")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                }
                
                // Social login buttons
                HStack(spacing: 20) {
                    // Apple Sign-In (icon-only)
                    Button(action: {
                        startAppleSignIn()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.black)
                                .frame(width: 56, height: 56)
                            Image(systemName: "applelogo")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Google Sign-In (placeholder - requires Google Sign-In SDK)
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            Text("G")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .font(AppTypography.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Sign Up")
                            .font(AppTypography.bodySmall)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
        .navigationDestination(isPresented: $showResetPassword) {
            ResetPasswordView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func login() {
        // Validate form
        guard !email.isEmpty else {
            showError = true
            errorMessage = "Please enter your email"
            return
        }
        
        guard !password.isEmpty else {
            showError = true
            errorMessage = "Please enter your password"
            return
        }
        
        isLoading = true
        showError = false
        
        let result = authService.loginUser(email: email, password: password)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            
            if let user = result.user {
                print("User Logged In Successfully:")
                print("Name: \(user.name)")
                print("Email: \(user.email)")
                
                // Set current user in app state
                appState.currentUser = user
                
                // Navigate to main app
                withAnimation {
                    appState.isLoggedIn = true
                }
            } else if let error = result.error {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func handleAppleSignIn(result: Swift.Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                print("Apple Sign-In Success:")
                print("User ID: \(userIdentifier)")
                print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
                print("Email: \(email ?? "")")
                
                // Create or login user with Apple credentials
                let name = "\(fullName?.givenName ?? "Apple") \(fullName?.familyName ?? "User")"
                let userEmail = email ?? "\(userIdentifier)@privaterelay.appleid.com"
                
                // Try to login with existing user or create new one
                let loginResult = authService.loginUser(email: userEmail, password: "")
                
                if let user = loginResult.user {
                    appState.currentUser = user
                    withAnimation {
                        appState.isLoggedIn = true
                    }
                } else {
                    // Create new user with Apple credentials
                    let registerResult = authService.registerUser(
                        name: name,
                        email: userEmail,
                        phoneNumber: "",
                        password: userIdentifier // Use Apple ID as password
                    )
                    
                    if let user = registerResult.user {
                        appState.currentUser = user
                        withAnimation {
                            appState.isLoggedIn = true
                        }
                    }
                }
            }
        case .failure(let error):
            print("Apple Sign-In Failed: \(error.localizedDescription)")
            showError = true
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }

    private func startAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let coordinator = AppleSignInCoordinator { result in
            handleAppleSignIn(result: result)
        }
        controller.delegate = coordinator
        controller.presentationContextProvider = coordinator
        coordinator.retainForLifetime(of: controller)
        controller.performRequests()
    }

    private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        private let completion: (Swift.Result<ASAuthorization, Error>) -> Void
        private var retainedController: ASAuthorizationController?

        init(completion: @escaping (Swift.Result<ASAuthorization, Error>) -> Void) {
            self.completion = completion
        }

        func retainForLifetime(of controller: ASAuthorizationController) {
            retainedController = controller
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            completion(.success(authorization))
            retainedController = nil
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            completion(.failure(error))
            retainedController = nil
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            let window = scenes
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            return window ?? ASPresentationAnchor()
        }
    }
    
    private func handleGoogleSignIn() {
        // TODO: Implement Google Sign-In SDK integration
        // This requires:
        // 1. Add Google Sign-In SDK via SPM
        // 2. Configure Google Cloud Console
        // 3. Add GoogleService-Info.plist
        // 4. Implement GIDSignIn configuration
        
        print("Google Sign-In clicked - SDK integration required")
        showError = true
        errorMessage = "Google Sign-In requires SDK integration. Please configure Google Sign-In SDK."
    }
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var disableAutocapitalization: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary.opacity(0.7))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(disableAutocapitalization ? .none : .sentences)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct SocialButton: View {
    var icon: String
    var isSystem: Bool = true
    
    var body: some View {
        Button(action: {}) {
            if isSystem {
                Image(systemName: icon)
                    .font(.title3)
            } else {
                // Placeholder for custom image
                Text("G")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .frame(width: 60, height: 60)
        .background(AppColors.cardBackground)
        .foregroundColor(AppColors.textPrimary)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}
