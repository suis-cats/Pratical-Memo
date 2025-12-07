//
//  NoteListView.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    
    let selectionType: SidebarSelection?
    @Binding var selectedNote: Note?
    
    @Query private var queriedNotes: [Note]
    
    init(selection: SidebarSelection?, selectedNote: Binding<Note?>) {
        self.selectionType = selection
        self._selectedNote = selectedNote
        
        let predicate: Predicate<Note>
        if let selection {
            switch selection {
            case .all:
                predicate = #Predicate<Note> { $0.deletedAt == nil }
            case .trash:
                predicate = #Predicate<Note> { $0.deletedAt != nil }
            case .folder(let folder):
                let targetID = folder.persistentModelID
                predicate = #Predicate<Note> { $0.deletedAt == nil && $0.folder?.persistentModelID == targetID }
            }
        } else {
            predicate = #Predicate<Note> { $0.deletedAt == nil }
        }
        
        self._queriedNotes = Query(filter: predicate, sort: \.updatedAt, order: .reverse)
    }
    
    var notes: [Note] {
        return sortNotes(queriedNotes)
    }
    
    // Header View
    // Custom Top Bar (Back Button + Menu)
    private var customTopBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            // Edit / Menu
            #if os(iOS)
            if editMode?.wrappedValue.isEditing == true {
                Button("完了") {
                    withAnimation {
                        editMode?.wrappedValue = .inactive
                        selection.removeAll()
                    }
                }
                .fontWeight(.bold)
            } else {
                menuContent
            }
            #else
            menuContent
            #endif
        }
        .padding(.horizontal)
        .padding(.top, 10) // Status bar spacing
        .padding(.bottom, 0)
    }

    // Header Title View
    private var headerTitleView: some View {
        HStack {
            Text(navigationTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 0) // Tight spacing
        .padding(.bottom, 5)   // Minimal gap before list
    }
    
    // Sort Logic
    private func sortNotes(_ notes: [Note]) -> [Note] {
        switch sortOption {
        case .dateEdited:
            return notes.sorted { $0.updatedAt > $1.updatedAt }
        case .dateCreated:
            return notes.sorted { $0.createdAt > $1.createdAt }
        case .title:
            return notes.sorted { $0.title < $1.title }
        }
    }

    // Pinned/Unpinned
    var pinnedNotes: [Note] {
        let filtered = filteredNotes
        return filtered.filter { $0.isPinned }
    }
    
    var unpinnedNotes: [Note] {
        let filtered = filteredNotes
        return filtered.filter { !$0.isPinned }
    }
    
    // Search Filter
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Date Grouping (for Unpinned)
    var groupedNotes: [(String, [Note])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: unpinnedNotes) { note -> String in
            if calendar.isDateInToday(note.updatedAt) {
                return "今日"
            } else if calendar.isDateInYesterday(note.updatedAt) {
                return "昨日"
            } else if calendar.isDate(note.updatedAt, equalTo: Date(), toGranularity: .weekOfYear) {
                return "今週"
            } else if calendar.isDate(note.updatedAt, equalTo: Date(), toGranularity: .month) {
                return "今月"
            } else {
                return "以前"
            }
        }
        
        let order = ["今日", "昨日", "今週", "今月", "以前"]
        return order.compactMap { key in
            guard let notes = grouped[key], !notes.isEmpty else { return nil }
            return (key, sortNotes(notes))
        }
    }
    
    @State private var searchText = ""
    @State private var navigateToNewNote = false
    @FocusState private var isSearchFocused: Bool
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var selection = Set<Note>()
    
    @State private var isGalleryView = false
    @State private var sortOption: SortOption = .dateEdited
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dateEdited = "編集日"
        case dateCreated = "作成日"
        case title = "タイトル"
        var id: String { rawValue }
    }
    
    @State private var isChatActive = false
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack {
            if isChatActive {
                ChatView(searchText: $searchText, namespace: animationNamespace, onDismiss: {
                    searchText = "" // Clear text on dismiss
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isChatActive = false
                    }
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            } else {
                // MAIN NOTE LIST CONTENT
                ZStack(alignment: .bottom) {
                    Color.glassBackground.ignoresSafeArea()
                    
                    if isGalleryView {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                customTopBar
                                headerTitleView
                                
                                if !pinnedNotes.isEmpty {
                                    notesGridSection(title: "ピン留め", notes: pinnedNotes)
                                }
                                
                                ForEach(groupedNotes, id: \.0) { section in
                                    notesGridSection(title: section.0, notes: section.1)
                                }
                                Color.clear.frame(height: 100)
                            }
                            // .padding(.top) // Removed top padding
                        }
                    } else {
                        // MANUAL HEADER LAYOUT (To fix whitespace)
                        VStack(spacing: 0) {
                            customTopBar
                            headerTitleView
                            
                            List(selection: $selection) {
                                if notes.isEmpty {
                                    Text("メモがありません")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .listRowSeparator(.hidden)
                                }
                                
                                ForEach(groupedNotes, id: \.0) { sectionTitle, notes in
                                    Section(header: Text(sectionTitle).font(.headline).fontWeight(.bold).foregroundStyle(Color.primary)) {
                                        ForEach(notes) { note in
                                            noteRow(note: note)
                                        }
                                    }
                                }
                            }
                            #if os(iOS)
                            .listStyle(.insetGrouped)
                            .environment(\.editMode, editMode)
                            .listSectionSpacing(0) // Remove default spacing between sections
                            #else
                            .listStyle(.sidebar)
                            #endif
                            .scrollContentBackground(.hidden)
                            .navigationDestination(for: Note.self) { note in
                                NoteDetailView(note: note, selectedNote: $selectedNote)
                                    .onAppear { selectedNote = note }
                            }
                            .navigationDestination(isPresented: $navigateToNewNote) {
                                if let note = selectedNote {
                                    NoteDetailView(note: note, selectedNote: $selectedNote)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("") // Hide title text
                #if os(iOS)
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline) // Minimal height
                .toolbar(.hidden, for: .navigationBar) // Hide standard navbar completely
                #endif
                .toolbar {
                     // Empty Toolbar (Items moved to Custom Header)
                    ToolbarItemGroup(placement: .bottomBar) {
                        #if os(iOS)
                        if editMode?.wrappedValue.isEditing == true {
                             // Edit Mode Toolbar
                            Button(action: {}) {
                                VStack(spacing: 0) {
                                    Image(systemName: "folder")
                                }
                            }
                            .disabled(selection.isEmpty)
                            
                            Spacer()
                            
                            Text("\(selection.count) 件選択")
                                .font(.caption)
                            
                            Spacer()
                            
                            Button(action: deleteSelectedNotes) {
                                VStack(spacing: 0) {
                                    Image(systemName: "trash")
                                }
                            }
                            .tint(.red)
                            .disabled(selection.isEmpty)
                        }
                        #endif
                    }
                }
                // Floating Glass Elements (Restored)
                .overlay(alignment: .bottom) {
                     if !isGalleryView {
                        VStack {
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 8) {
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    
                                    if !isChatActive {
                                        TextField("Search", text: $searchText)
                                            .focused($isSearchFocused)
                                            .submitLabel(.search)
                                            .matchedGeometryEffect(id: "searchBubble", in: animationNamespace)
                                            .onSubmit {
                                                isSearchFocused = false
                                            }
                                    } else {
                                        Text("Search")
                                            .font(.body)
                                            .hidden()
                                    }
                                    
                                    if !searchText.isEmpty {
                                        Button(action: {
                                            searchText = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if isSearchFocused {
                                        Button(action: {
                                            self.speechRecognizer.isRecording.toggle()
                                        }) {
                                            Image(systemName: speechRecognizer.isRecording ? "waveform.circle.fill" : "mic.fill")
                                                .foregroundColor(speechRecognizer.isRecording ? .red : .secondary)
                                        }
                                    }
                                }
                                .padding(12)
                                .frame(height: 46) // Exact 45pt
                                .refractiveGlass(cornerRadius: 23) // Fully rounded
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                                
                                // Close Keyboard Button (Appears when focused)
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
                                
                                // Send Button (Paperplane UP)
                                Button(action: {
                                    if isSearchFocused {
                                        // TRIGGER CHAT TRANSITION
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            isChatActive = true
                                            isSearchFocused = false
                                        }
                                    } else {
                                        addNote()
                                    }
                                }) {
                                    Image(systemName: isSearchFocused ? "paperplane" : "square.and.pencil") // Paperplane
                                        .font(.title2)
                                        .rotationEffect(.degrees(isSearchFocused ? -45 : 0)) // -45 deg to point UP
                                        .offset(x: isSearchFocused ? 0.5 : 0, y: isSearchFocused ? 1.5 : 0) // Optical bracket 3
                                        .foregroundStyle(Color.primary)
                                        .frame(width: 46, height: 46) // Exact 45pt
                                        .refractiveGlass(cornerRadius: 23)
                                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                                        .accessibilityIdentifier("FloatingActionButton")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, -30) // Negative padding to counteract List top spacing
                            .padding(.bottom, 0) // Reduced to 0
                        }
                    }
                }
            }
        }
        .onChange(of: speechRecognizer.transcript) { oldValue, newValue in
            if !newValue.isEmpty {
                searchText = newValue
            }
        }
    }
    
    private var navigationTitle: String {
        switch selectionType {
        case .all: return "すべてのメモ"
        case .trash: return "最近削除した項目"
        case .folder(let f): return f.name
        case .none: return "すべてのメモ"
        }
    }

    // MARK: - Subviews (Rows, Grid, Logic)
    // Note: private var normalToolbar, selectionToolbar, floatingBottomBar removed.
    
    private func noteRow(note: Note) -> some View {
        NavigationLink {
            NoteDetailView(note: note, selectedNote: $selectedNote)
                .onAppear { selectedNote = note }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    Text(note.title.isEmpty ? "新規メモ" : note.title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                }
                
                HStack(spacing: 6) {
                    Text(note.updatedAt.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(.secondary)
                    
                    Text(note.content.isEmpty ? "追加テキストなし" : note.content)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
            .padding(.vertical, 0)
            .frame(height: 60) // User requested exact 60pt
        }
        .listRowBackground(Color.glassSecondaryBackground)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)) // Force tighter insets
        .listRowSeparator(.hidden) // Cleaner look
        .swipeActions(edge: .trailing, allowsFullSwipe: true) { 
            Button(role: .destructive) { deleteNote(note) } label: { Label(isInTrash ? "完全に削除" : "削除", systemImage: "trash") }
        }
        .contextMenu {
            contextMenuButtons(for: note)
        } preview: {
            NoteDetailView(note: note, selectedNote: .constant(nil))
                 .frame(width: 380, height: 550) // Fixed width to fill screen (approx)
                 .clipShape(RoundedRectangle(cornerRadius: 12)) // Ensure clean corners
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) { 
             if isInTrash {
                 Button { restoreNote(note) } label: { Label("復元", systemImage: "arrow.uturn.backward") }
                     .tint(.blue)
             } else {
                 Button { note.isPinned.toggle() } label: { Label(note.isPinned ? "ピン留めを解除" : "ピン留め", systemImage: note.isPinned ? "pin.slash" : "pin") }
                     .tint(.orange)
             }
        }
    }
    
    private func notesGridSection(title: String, notes: [Note]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(notes) { note in
                    NavigationLink {
                        NoteDetailView(note: note, selectedNote: $selectedNote)
                            .onAppear { selectedNote = note }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.title.isEmpty ? "新規メモ" : note.title)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                            
                            Text(note.content.isEmpty ? "追加テキストなし" : note.content)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Text(note.updatedAt.formatted(date: .numeric, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12) // Standard internal padding
                        .frame(height: 150) // Proper height for gallery card
                        .background(Color.glassSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain) // Prevent default button styling constraints
                    .contextMenu {
                        contextMenuButtons(for: note)
                    } preview: {
                        NoteDetailView(note: note, selectedNote: .constant(nil))
                            .frame(width: 380, height: 550) // Fixed width
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Shared Context Menu Buttons
    @ViewBuilder
    private func contextMenuButtons(for note: Note) -> some View {
        Button(role: .destructive) { deleteNote(note) } label: { Label(isInTrash ? "完全に削除" : "削除", systemImage: "trash") }
        Button { note.isPinned.toggle() } label: { Label(note.isPinned ? "ピン留めを解除" : "ピン留め", systemImage: note.isPinned ? "pin.slash" : "pin") }
        if isInTrash {
            Button { restoreNote(note) } label: { Label("復元", systemImage: "arrow.uturn.backward") }
        }
    }
    
    // REMOVED private vars: floatingBottomBar, normalToolbar, selectionToolbar
    
    private var menuContent: some View {
        Menu {
            Section {
                Button(action: { isGalleryView.toggle() }) {
                    Label(isGalleryView ? "リスト表示" : "ギャラリー表示", systemImage: isGalleryView ? "list.bullet" : "square.grid.2x2")
                }
            }
            
            Section(header: Text("表示順序")) {
                Picker("並び替え", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
            
            Section {
                Button(action: {
                    withAnimation {
                        isGalleryView = false 
                        #if os(iOS)
                        editMode?.wrappedValue = .active
                        #endif
                    }
                }) { Label("メモを選択", systemImage: "checkmark.circle") }
            }
        } label: {
            // Updated Ellipsis Button Style (Circular, Plain Icon)
            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44) // Standard touch target
                .background(Color.glassSecondaryBackground.opacity(0.5)) // Subtle background check
                .clipShape(Circle())
        }
    }
    
    private var isInTrash: Bool {
        if case .trash = selectionType { return true }
        return false
    }
    
    private func addNote() {
        // Can't add to trash
        var targetFolder: Folder? = nil
        if case .folder(let f) = selectionType {
            targetFolder = f
        }
        let newNote = Note(title: "", content: "", folder: targetFolder)
        modelContext.insert(newNote)
        selectedNote = newNote
        navigateToNewNote = true
    }
    
    private func deleteNote(_ note: Note) {
        withAnimation {
            if isInTrash {
                modelContext.delete(note)
            } else {
                note.deletedAt = Date()
            }
            if selection.contains(note) {
                selection.remove(note)
            }
        }
    }
    
    private func restoreNote(_ note: Note) {
        withAnimation {
            note.deletedAt = nil
        }
    }
    
    private func deleteSelectedNotes() {
        withAnimation {
            let notesToDelete = Array(selection)
            for note in notesToDelete {
                if isInTrash {
                    modelContext.delete(note)
                } else {
                    note.deletedAt = Date()
                }
            }
            selection.removeAll()
            #if os(iOS)
            editMode?.wrappedValue = .inactive
            #endif
        }
    }
}
