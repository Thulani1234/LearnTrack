import SwiftUI

struct HelpCenterView: View {
    @EnvironmentObject var router: AppRouter
    @State private var searchText = ""
    
    let categories = [
        HelpCategory(title: "Getting Started", icon: "sparkles", color: .blue),
        HelpCategory(title: "Study Timer", icon: "timer", color: .orange),
        HelpCategory(title: "Notes", icon: "doc.text.fill", color: .purple),
        HelpCategory(title: "Account", icon: "person.fill", color: .green),
        HelpCategory(title: "Live Study", icon: "video.fill", color: .red),
        HelpCategory(title: "Billing", icon: "creditcard.fill", color: .cyan)
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
                Text("Help Center")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Rectangle().fill(Color.clear).frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Search Bar
                    VStack(spacing: 16) {
                        Text("How can we help?")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            TextField("Search help articles...", text: $searchText)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // Categories Grid
                    VStack(alignment: .leading, spacing: 20) {
                        Text("CATEGORIES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(categories) { category in
                                HelpCategoryCard(category: category)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("FREQUENTLY ASKED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                        
                        VStack(spacing: 0) {
                            FAQRow(question: "How to export study notes?")
                            Divider()
                            FAQRow(question: "Can I study with friends offline?")
                            Divider()
                            FAQRow(question: "Resetting my study goals")
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct HelpCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct HelpCategoryCard: View {
    let category: HelpCategory
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .font(.system(size: 20, weight: .bold))
            }
            
            Text(category.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}

struct FAQRow: View {
    let question: String
    
    var body: some View {
        HStack {
            Text(question)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.3))
        }
        .padding()
    }
}
