import SwiftUI

struct MemoEditorView: View {
    @Bindable var note: Note
    @FocusState.Binding var focus: NoteDetailView.FocusField?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Header
                if let imageData = note.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            Button(action: {
                                withAnimation {
                                    note.imageData = nil
                                }
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.white, .red)
                                    .padding(8)
                            }
                        }
                }
                
                // Title
                TextField("Title", text: $note.title)
                    .font(.system(size: 34, weight: .bold))
                    .padding(.horizontal)
                    .focused($focus, equals: .title)
                    .submitLabel(.next)
                    .onSubmit {
                        focus = .content
                    }
                
                // Content
                TextEditor(text: $note.content)
                    .font(.body)
                    .frame(minHeight: 300)
                    .padding(.horizontal)
                    .focused($focus, equals: .content)
                    .scrollContentBackground(.hidden)
            }
            .padding(.top)
        }
    }
}
