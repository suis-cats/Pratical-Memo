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
    @Binding var selection: SidebarSelection?
    
    @State private var showingAddFolderAlert = false
    @State private var newFolderName = ""
    
    var body: some View {
        List(selection: $selection) {
            Section {
                NavigationLink(value: SidebarSelection.all) {
                    Label("すべてのメモ", systemImage: "tray")
                }
                
                NavigationLink(value: SidebarSelection.trash) {
                    Label("最近削除した項目", systemImage: "trash")
                }
            } header: {
                Text("ライブラリ")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Section {
                ForEach(folders) { folder in
                    NavigationLink(value: SidebarSelection.folder(folder)) {
                        Label(folder.name, systemImage: folder.iconName)
                    }
                }
                .onDelete(perform: deleteFolders)
            } header: {
                Text("フォルダ")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("フォルダ")
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
        .alert("新規フォルダ", isPresented: $showingAddFolderAlert) {
            TextField("フォルダ名", text: $newFolderName)
            Button("キャンセル", role: .cancel) { newFolderName = "" }
            Button("保存") {
                addFolder()
                newFolderName = ""
            }
        }
    }
    
    private func addFolder() {
        let folder = Folder(name: newFolderName.isEmpty ? "新規フォルダ" : newFolderName)
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
