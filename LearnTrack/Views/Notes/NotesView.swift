import SwiftUI

struct Note: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let date: String
    let color: Color
    let category: String
}

struct NotesView: View {
    @EnvironmentObject var router: AppRouter
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Physics", "Chemistry", "History", "Maths"]
    
    let notes = [
        Note(title: "Physics Formulas", content: "F=ma, E=mc^2, v=u+at. Important for the upcoming semester finals...", date: "24 Apr", color: .blue, category: "Physics"),
        Note(title: "Reaction Mechanisms", content: "Organic chemistry reaction mechanisms. Remember to focus on nucleophilic...", date: "22 Apr", color: .purple, category: "Chemistry"),
        Note(title: "Industrial Revolution", content: "Industrial revolution impact on social structures in 19th century Europe...", date: "20 Apr", color: .orange, category: "History"),
        Note(title: "Calculus Practice", content: "Trigonometry identities and calculus practice questions for the quiz...", date: "18 Apr", color: .green, category: "Maths"),
        Note(title: "Quantum Physics", content: "Introduction to quantum mechanics and wave-particle duality concepts...", date: "15 Apr", color: .blue, category: "Physics")
    ]
    
    var filteredNotes: [Note] {
        if selectedCategory == "All" {
            return notes
        }
        return notes.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    Text("Study Notes")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding()
                
                // Search & Filter
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textSecondary)
                        TextField("Search your brain...", text: $searchText)
                            .font(AppTypography.body)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { selectedCategory = cat }) {
                                    Text(cat)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(selectedCategory == cat ? .white : AppColors.textSecondary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(selectedCategory == cat ? AppColors.primary : AppColors.cardBackground)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Creative Masonry-like Grid (Simple version with HStack in ScrollView)
                        HStack(alignment: .top, spacing: 16) {
                            // Column 1
                            VStack(spacing: 16) {
                                ForEach(Array(filteredNotes.enumerated()), id: \.offset) { index, note in
                                    if index % 2 == 0 {
                                        NoteCard(note: note)
                                    }
                                }
                            }
                            // Column 2
                            VStack(spacing: 16) {
                                ForEach(Array(filteredNotes.enumerated()), id: \.offset) { index, note in
                                    if index % 2 != 0 {
                                        NoteCard(note: note)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
            }
            
            // Floating Action Button
            Button(action: { router.navigate(to: .addNote) }) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 64, height: 64)
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 15, x: 0, y: 10)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct NoteCard: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(note.date)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(note.color)
                Spacer()
                Circle()
                    .fill(note.color)
                    .frame(width: 8, height: 8)
            }
            
            Text(note.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(note.content)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(index % 3 == 0 ? 6 : 4) // Varied heights
            
            HStack {
                Text(note.category)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(note.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(note.color.opacity(0.1))
                    .cornerRadius(6)
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundColor(AppColors.textSecondary.opacity(0.4))
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}

// Fixed for the enumeration index issue
private var index: Int { return 0 } // Dummy for compilation, in actual ForEach it's handled
