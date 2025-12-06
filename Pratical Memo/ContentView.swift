//
//  ContentView.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedFolder: Folder?
    @State private var selectedNote: Note?
    @State private var visibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView(selectedFolder: $selectedFolder)
        } content: {
            NoteListView(folder: selectedFolder, selectedNote: $selectedNote)
                .navigationDestination(for: Note.self) { note in
                    NoteDetailView(note: note)
                }
        } detail: {
            // Background view when no note is selected (iPad/Mac)
            Text("Select a Note")
                .font(.title)
                .foregroundStyle(.secondary)
                .liquidGlass(cornerRadius: 20, depth: 0.5)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Note.self], inMemory: true)
}
