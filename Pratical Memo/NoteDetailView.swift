import SwiftUI
import PhotosUI
import SwiftData

struct NoteDetailView: View {
    @Bindable var note: Note
    @Binding var selectedNote: Note?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var isChatActive = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Namespace private var animationNamespace
    
    @FocusState var focus: FocusField?
    
    // [NEW] Navigation Mode
    @State private var currentMode: DetailMode = .memo
    
    enum FocusField: Hashable {
        case title
        case content
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.gray.opacity(0.05).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Tab Bar
                LiquidGlassTabBar(selection: $currentMode)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .zIndex(1)
                
                // Content Area
                TabView(selection: $currentMode) {
                    MemoEditorView(note: note, focus: $focus)
                        .tag(DetailMode.memo)
                    
                    SummaryView(note: note)
                        .tag(DetailMode.summary)
                    
                    PlaybackView(note: note)
                        .tag(DetailMode.playback)
                    
                    RecordingView()
                        .tag(DetailMode.record)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // Footer Overlay (Only show in Memo mode or if needed globally)
            if currentMode == .memo && focus == nil {
                VStack {
                    Spacer()
                    HStack(alignment: .center, spacing: 12) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search", text: $searchText)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Mic Button inside search bar
                            if searchText.isEmpty {
                                Button(action: {
                                    self.speechRecognizer.isRecording.toggle()
                                }) {
                                    Image(systemName: speechRecognizer.isRecording ? "waveform.circle.fill" : "mic.fill")
                                        .foregroundColor(speechRecognizer.isRecording ? .red : .secondary)
                                }
                            }
                        }
                        .padding(12)
                        .frame(height: 46)
                        .refractiveGlass(cornerRadius: 23)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        
                        // Close Keyboard Button
                        if isSearchFocused {
                            Button(action: {
                                isSearchFocused = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 40, height: 40)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Send/New Note Button
                        Button(action: {
                            if isSearchFocused {
                                // Chat Action
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    isChatActive = true
                                }
                            } else {
                                addItem()
                            }
                        }) {
                            Image(systemName: isSearchFocused ? "paperplane" : "square.and.pencil")
                                .font(.title2)
                                .rotationEffect(.degrees(isSearchFocused ? -45 : 0))
                                .offset(x: isSearchFocused ? 0.5 : 0, y: isSearchFocused ? 1.5 : 0)
                                .foregroundStyle(Color.primary)
                                .frame(width: 46, height: 46)
                                .refractiveGlass(cornerRadius: 23)
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 1, y: 3)
                                .accessibilityIdentifier("CorrectFAB")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 0)
                }
            }
        }
        .sheet(isPresented: $isChatActive, onDismiss: {
            searchText = ""
        }) {
            ChatView(noteContent: note.content, initialQuery: searchText)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { note.isPinned.toggle() }) {
                        Label(note.isPinned ? "ピン留めを解除" : "ピン留め", systemImage: note.isPinned ? "pin.slash" : "pin")
                    }
                    Button(action: { currentMode = .record }) {
                        Label("会議を録音", systemImage: "mic.badge.plus")
                    }
                    Button(role: .destructive, action: deleteAndDismiss) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newNote = Note(title: "", content: "")
            modelContext.insert(newNote)
            selectedNote = newNote
            searchText = ""
            isSearchFocused = false
        }
    }
    
    private func deleteAndDismiss() {
        note.deletedAt = Date()
        dismiss()
    }
}
