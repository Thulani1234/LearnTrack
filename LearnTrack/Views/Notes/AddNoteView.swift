import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddNoteView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var data: MockData
    
let noteToEdit: Note?
    @State private var title = ""
    @State private var content = ""
    @State private var selectedColor = AppColors.primary
    @State private var selectedSubjectId: UUID?
    @State private var currentCategory = "General"
    private let colors: [Color] = [.blue, .purple, .orange, .pink, .green, .red, .cyan, .indigo]

    // Image/File Selection State
    @State private var selectedItem: PhotosPickerItem?
    @State private var noteAttachments: [NoteAttachment] = []
    @State private var showingFilePicker = false

    init(noteToEdit: Note? = nil) {
        self.noteToEdit = noteToEdit
        _title = State(initialValue: noteToEdit?.title ?? "")
        _content = State(initialValue: noteToEdit?.content ?? "")
        _selectedColor = State(initialValue: Color(hex: noteToEdit?.colorHex ?? "6366F1"))
        _noteAttachments = State(initialValue: noteToEdit?.attachments ?? [])
        _currentCategory = State(initialValue: noteToEdit?.category ?? "General")
        _selectedSubjectId = State(initialValue: nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    colorPicker
                    
                    subjectPicker
                    
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
        .onAppear {
            if selectedSubjectId == nil {
                selectedSubjectId = data.subjects.first(where: { $0.name == currentCategory })?.id
            }
        }
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
                    if let savedURL = try? copyFileToDocuments(from: url) {
                        withAnimation {
                            noteAttachments.append(NoteAttachment(id: UUID(), name: savedURL.lastPathComponent, path: savedURL.path, type: .document))
                        }
                    }
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
            Text(noteToEdit == nil ? "New Note" : "Edit Note")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: {
                let category = data.subjects.first(where: { $0.id == selectedSubjectId })?.name ?? currentCategory
                let savedNote = Note(
                    id: noteToEdit?.id ?? UUID(),
                    title: title.isEmpty ? "Untitled Note" : title,
                    content: content,
                    colorHex: selectedColor.toHex() ?? "6366F1",
                    category: category,
                    dateCreated: noteToEdit?.dateCreated ?? Date(),
                    attachments: noteAttachments
                )

                if noteToEdit != nil {
                    data.updateNote(savedNote)
                } else {
                    data.addNote(savedNote)
                }
                
                withAnimation {
                    appState.currentAlert = AppAlert(
                        title: noteToEdit == nil ? "Note Saved! " : "Note Updated! ",
                        message: title.isEmpty ? "Your note has been stored." : "'\(title)' is ready for review.",
                        icon: "doc.text.fill",
                        color: selectedColor,
                        type: .success
                    )
                }
                router.navigate(to: .noteDetail(savedNote))
            }) {
                Text(noteToEdit == nil ? "Save" : "Update")
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
    private var subjectPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LINK TO SUBJECT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.6))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.subjects) { subject in
                        Button(action: {
                            selectedSubjectId = subject.id
                            selectedColor = Color(hex: subject.colorHex)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: subject.icon)
                                    .font(.system(size: 14))
                                Text(subject.name)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedSubjectId == subject.id ? Color(hex: subject.colorHex) : AppColors.cardBackground)
                            .foregroundColor(selectedSubjectId == subject.id ? .white : AppColors.textPrimary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: subject.colorHex).opacity(0.3), lineWidth: selectedSubjectId == subject.id ? 0 : 1)
                            )
                        }
                    }
                }
            }
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
                    ForEach(noteAttachments) { attachment in
                        if attachment.isImage, let uiImage = UIImage(contentsOfFile: attachment.path) {
                            AttachmentCard(image: Image(uiImage: uiImage)) {
                                withAnimation {
                                    noteAttachments.removeAll(where: { $0.id == attachment.id })
                                }
                            }
                        } else {
                            FileAttachmentCard(name: attachment.name) {
                                withAnimation {
                                    noteAttachments.removeAll(where: { $0.id == attachment.id })
                                }
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
            guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
            let imageName = "note-image-\(UUID().uuidString.prefix(8)).jpg"
            let savedURL = await saveAttachmentData(data, fileName: imageName)
            await MainActor.run {
                if let savedURL {
                    withAnimation {
                        noteAttachments.append(NoteAttachment(id: UUID(), name: imageName, path: savedURL.path, type: .image))
                    }
                }
            }
        }
    }
    
    private func saveAttachmentData(_ data: Data, fileName: String) async -> URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documents else { return nil }
        let destination = documents.appendingPathComponent(fileName)
        let uniqueDestination = uniqueDocumentURL(for: destination)
        do {
            try data.write(to: uniqueDestination, options: .atomic)
            return uniqueDestination
        } catch {
            print("Attachment save failed: \(error)")
            return nil
        }
    }
    
    private func uniqueDocumentURL(for url: URL) -> URL {
        var finalURL = url
        var counter = 1
        while FileManager.default.fileExists(atPath: finalURL.path) {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension
            finalURL = url.deletingLastPathComponent().appendingPathComponent("\(fileName)-\(counter).\(fileExtension)")
            counter += 1
        }
        return finalURL
    }
    
    private func copyFileToDocuments(from url: URL) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documents else { throw NSError(domain: "NoteAttachment", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access documents folder"])
        }
        let destination = documents.appendingPathComponent(url.lastPathComponent)
        let uniqueDestination = uniqueDocumentURL(for: destination)
        try FileManager.default.copyItem(at: url, to: uniqueDestination)
        return uniqueDestination
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
