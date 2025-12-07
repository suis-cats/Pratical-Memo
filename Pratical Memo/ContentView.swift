//
//  ContentView.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedFolder: SidebarSelection? = .all // Default to All
    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedFolder)
        } content: {
            NoteListView(selection: selectedFolder, selectedNote: $selectedNote)
        } detail: {
            if let note = selectedNote {
                NoteDetailView(note: note, selectedNote: $selectedNote)
                    .id(note.id) // Force refresh if note changes
            } else {
                Text("Select a Note")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
