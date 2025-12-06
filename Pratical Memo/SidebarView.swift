//
//  SidebarView.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @Binding var selectedFolder: Folder?
    
    // Smart folder selection handling could be improved, 
    // but for now we'll focus on physical folders + "All Notes" concept
    // To handle "All Notes", we might treat selectedFolder == nil as "All" or use a special enum.
    // For simplicity in this clone, let's allow Folder creation.
    
    @State private var showingAddFolderAlert = false
    @State private var newFolderName = ""
    
    var body: some View {
        List(selection: $selectedFolder) {
            Section {
                // Mock "All Cloud" or Smart Folder
                // In a real app, this would query all notes.
                // For this UI clone, we focus on the visual structure.
                NavigationLink(value: Folder(name: "Quick Notes", iconName: "folder")) { // Temporary mock for UI
                     Label("All iCloud", systemImage: "icloud")
                }
                .disabled(true) // Disable fake link for now
                
                NavigationLink(value: Folder(name: "Notes", iconName: "note.text")) { // Temporary mock
                    Label("Notes", systemImage: "note.text")
                }
                .disabled(true) 
            } header: {
                Text("iCloud")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Section {
                ForEach(folders) { folder in
                    NavigationLink(value: folder) {
                        Label(folder.name, systemImage: folder.iconName)
                    }
                }
                .onDelete(perform: deleteFolders)
            } header: {
                Text("Folders")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Folders")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showingAddFolderAlert = true
                }) {
                    Image(systemName: "folder.badge.plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            #else
            ToolbarItem {
                Button(action: {
                    showingAddFolderAlert = true
                }) {
                    Image(systemName: "folder.badge.plus")
                }
            }
            #endif
        }
        .alert("New Folder", isPresented: $showingAddFolderAlert) {
            TextField("Name", text: $newFolderName)
            Button("Cancel", role: .cancel) { newFolderName = "" }
            Button("Save") {
                addFolder()
                newFolderName = ""
            }
        }
    }
    
    private func addFolder() {
        let folder = Folder(name: newFolderName.isEmpty ? "New Folder" : newFolderName)
        modelContext.insert(folder)
    }

    private func deleteFolders(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(folders[index])
            }
        }
    }
}
