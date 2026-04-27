import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AttachedImage: Identifiable {
    let id = UUID()
    let image: Image
}

struct AddNoteView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedColor = AppColors.primary
    
    // Image/File Selection State
    @State private var selectedItem: PhotosPickerItem?
    @State private var attachedImages: [AttachedImage] = []
    @State private var showingFilePicker = false
    @State private var attachedFiles: [String] = []
    
    let colors: [Color] = [.blue, .purple, .orange, .pink, .green, .red, .cyan, .indigo]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    colorPicker
                    
                    VStack(alignment: .leading, spacing: 12) {
                        titleField
                        Divider()
                        contentEditor
                        attachmentsSection
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: selectedItem) { newItem in
            handleImageSelection(newItem)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf, .text, .plainText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    attachedFiles.append(url.lastPathComponent)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
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
            Text("New Note")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { 
                withAnimation {
                    appState.currentAlert = AppAlert(
                        title: "Note Saved! 📝",
                        message: title.isEmpty ? "Your new note has been stored." : "'\(title)' is ready for review.",
                        icon: "doc.text.fill",
                        color: selectedColor,
                        type: .success
                    )
                }
                router.navigateBack() 
            }) {
                Text("Save")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .opacity(selectedColor == color ? 1 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.vertical, 5)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var titleField: some View {
        TextField("Title", text: $title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(AppColors.textPrimary)
    }
    
    @ViewBuilder
    private var contentEditor: some View {
        TextEditor(text: $content)
            .font(AppTypography.body)
            .foregroundColor(AppColors.textPrimary)
            .frame(minHeight: 200)
            .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ATTACHMENTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                Spacer()
                Menu {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Photo Library", systemImage: "photo.on.rectangle")
                    }
                    
                    Button(action: { showingFilePicker = true }) {
                        Label("Browse Files", systemImage: "folder")
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Media")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Attached Files (Documents)
                    ForEach(attachedFiles, id: \.self) { fileName in
                        FileAttachmentCard(name: fileName) {
                            withAnimation {
                                attachedFiles.removeAll(where: { $0 == fileName })
                            }
                        }
                    }
                    
                    // Attached Images
                    ForEach(attachedImages) { item in
                        AttachmentCard(image: item.image) {
                            withAnimation {
                                attachedImages.removeAll(where: { $0.id == item.id })
                            }
                        }
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                                .foregroundColor(AppColors.textSecondary.opacity(0.3))
                        }
                        .frame(width: 100, height: 100)
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.textSecondary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    private func handleImageSelection(_ newItem: PhotosPickerItem?) {
        guard let newItem else { return }
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation {
                            attachedImages.append(AttachedImage(image: Image(uiImage: uiImage)))
                        }
                    }
                }
            }
        }
    }
}

struct AttachmentCard: View {
    let image: Image
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .background(Color.black.opacity(0.3).clipShape(Circle()))
                    .padding(8)
            }
        }
    }
}

struct FileAttachmentCard: View {
    let name: String
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.primary)
                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
            .frame(width: 130, height: 130)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppColors.primary.opacity(0.1), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .background(Color.black.opacity(0.3).clipShape(Circle()))
                    .padding(8)
            }
        }
    }
}
