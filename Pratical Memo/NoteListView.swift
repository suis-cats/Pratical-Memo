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
    let folder: Folder?
    
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    
    var notes: [Note] {
        if let folder = folder {
            return folder.notes?.sorted(by: { $0.updatedAt > $1.updatedAt }) ?? []
        } else {
            return allNotes
        }
    }
    
    // Separate pinned and unpinned notes
    var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }
    
    var unpinnedNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }
    
    // Filtered notes based on search
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    @Binding var selectedNote: Note?
    @State private var searchText = ""
    @State private var navigateToNewNote = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.glassBackground.ignoresSafeArea()
            


            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView

                    // Pinned Notes Section
                        if !pinnedNotes.isEmpty {
                            notesSectionView(title: "Pinned", notes: pinnedNotes)
                        }
                        
                        // Regular Notes Section
                        if !unpinnedNotes.isEmpty {
                            notesSectionView(title: "Notes", notes: unpinnedNotes)
                        }
                        
                        // Spacer for bottom bar
                        Color.clear.frame(height: 100)
                    }
                    .padding(.top)
                }

            
            floatingBottomBar
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToNewNote) {
            NoteDetailView(note: selectedNote ?? Note())
        }
    }

    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(folder?.name ?? "All Notes")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(notes.count) items")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func notesSectionView(title: String, notes: [Note]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            // Card Container
            VStack(spacing: 0) {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    noteRow(note: note, index: index, totalCount: notes.count)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
    
    private func noteRow(note: Note, index: Int, totalCount: Int) -> some View {
        VStack(spacing: 0) {
            NavigationLink(value: note) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if note.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            Text(note.title.isEmpty ? "New Note" : note.title)
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                        }
                        
                        HStack(spacing: 6) {
                            Text(note.updatedAt.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(.secondary)
                            
                            Text(note.content.isEmpty ? "No Additional Text" : note.content)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    deleteNote(note)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    note.isPinned.toggle()
                } label: {
                    Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                }
                .tint(.orange)
            }
            
            if index < totalCount - 1 {
                Divider()
                    .padding(.leading)
            }
        }
    }

    private var floatingBottomBar: some View {
        HStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                TextField("Search", text: $searchText)
                    .font(.body)
                Image(systemName: "mic.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16) // Increased size
            .padding(.horizontal, 20)
            .liquidGlass(cornerRadius: 30, depth: 1.0)
            .liquidDrag()
            
            // Compose Button
            Button(action: addNote) {
                Image(systemName: "square.and.pencil")
                    .font(.title2) // Larger Icon
                    .foregroundStyle(Color.glassText)
                    .padding(16) // Larger Area
                    .liquidGlass(cornerRadius: 30, depth: 1.2)
                    .clipShape(Circle())
            }
            .liquidDrag()
        }
        .padding(.horizontal)
        .padding(.bottom, 20) // More bottom clearance
    }
    
    private func addNote() {
        let newNote = Note(title: "", content: "", folder: folder)
        modelContext.insert(newNote)
        selectedNote = newNote
        navigateToNewNote = true
    }
    
    private func deleteNote(_ note: Note) {
        withAnimation {
            modelContext.delete(note)
        }
    }
}
