import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var router: AppRouter
    @AppStorage("useFaceID") private var useFaceID = true
    @AppStorage("pushNotifications") private var pushNotifications = true
    @State private var selectedTheme = "System"
    @State private var reminderFrequency = "Daily"
    
    let themes = ["Light", "Dark", "System"]
    let frequencies = ["Daily", "Weekly", "Only Exams"]
    
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
                Text("Settings")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Security Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SECURITY")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        ToggleItem(icon: "faceid", title: "Face ID / Touch ID", isOn: $useFaceID, color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NOTIFICATIONS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        VStack(spacing: 0) {
                            ToggleItem(icon: "bell.fill", title: "Push Notifications", isOn: $pushNotifications, color: .red)
                            Divider().padding(.leading, 60)
                            PickerItem(icon: "clock.fill", title: "Reminders", selection: $reminderFrequency, options: frequencies, color: .orange)
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    
                    // Appearance Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("APPEARANCE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        PickerItem(icon: "paintbrush.fill", title: "App Theme", selection: $selectedTheme, options: themes, color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // Support & Data Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SUPPORT & DATA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        VStack(spacing: 0) {
                            ActionItem(icon: "doc.text.fill", title: "Privacy Policy", color: .green)
                            Divider().padding(.leading, 60)
                            ActionItem(icon: "trash.fill", title: "Clear Study Data", color: .red, isDestructive: true)
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    
                    // Version
                    VStack(spacing: 4) {
                        Text("LearnTrack Premium")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Version 1.2.4")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.vertical, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ToggleItem: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
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
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(24)
    }
}

struct PickerItem: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    let color: Color
    
    var body: some View {
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
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selection)
                        .foregroundColor(AppColors.textSecondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))
                }
            }
        }
        .padding()
    }
}

struct ActionItem: View {
    let icon: String
    let title: String
    let color: Color
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .cornerRadius(10)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? .red : AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.3))
            }
            .padding()
        }
    }
}
