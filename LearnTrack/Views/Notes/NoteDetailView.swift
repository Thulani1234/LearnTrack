import SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var router: AppRouter
    @Environment(\.openURL) private var openURL
    let note: Note
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(note.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        HStack(spacing: 10) {
                            Text(note.dateString)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                            Text(note.category)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(note.color.opacity(0.9))
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text(note.content)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(AppColors.cardBackground)
                        .cornerRadius(24)
                        .padding(.horizontal)
                    
                    if !note.attachments.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Attachments")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(note.attachments) { attachment in
                                    NoteAttachmentCard(attachment: attachment) {
                                        openAttachment(attachment)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
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
            Text("Note")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Circle().fill(Color.clear).frame(width: 44, height: 44)
        }
        .padding()
    }
    
    private func openAttachment(_ attachment: NoteAttachment) {
        openURL(attachment.url)
    }
}

private struct NoteAttachmentCard: View {
    let attachment: NoteAttachment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if attachment.isImage, let image = UIImage(contentsOfFile: attachment.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 110)
                        .clipped()
                        .cornerRadius(20)
                } else {
                    Spacer()
                    Image(systemName: "doc.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                    Text(attachment.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(attachment.isImage ? 0 : 14)
            .background(AppColors.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
