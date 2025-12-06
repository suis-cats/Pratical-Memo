//
//  NoteDetailView.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI

struct NoteDetailView: View {
    @Bindable var note: Note
    @FocusState private var focus: Field?
    
    enum Field {
        case title
        case content
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Date Header
                    HStack {
                        Spacer()
                        Text(note.updatedAt.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top)

                    TextField("Title", text: $note.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .submitLabel(.next)
                            .focused($focus, equals: .title)
                            .onSubmit {
                                focus = .content
                            }
                        
                        TextEditor(text: $note.content)
                            .font(.body)
                            .frame(minHeight: 300)
                            .scrollContentBackground(.hidden)
                            .focused($focus, equals: .content)
                    }
                    .padding()
                }
            .background {
                ZStack {
                    Color.glassBackground.ignoresSafeArea()
                    
                    // Subtle gradient orb for "Liquid" feel
                    GeometryReader { proxy in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.blue.opacity(0.1), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 200
                                )
                            )
                            .frame(width: 300, height: 300)
                            .position(x: proxy.size.width, y: 0)
                            .blur(radius: 50)
                    }
                }
            }
            
            // Formatting Toolbar
            if focus != nil {
                formattingToolbar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { note.isPinned.toggle() }) {
                        Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                    }
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onChange(of: note.title) { _, _ in note.updatedAt = Date() }
        .onChange(of: note.content) { _, _ in note.updatedAt = Date() }
    }
    
    private var formattingToolbar: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Image(systemName: "list.bullet")
            }
            
            Button(action: {}) {
                Image(systemName: "textformat")
            }
            
            Button(action: {}) {
                Image(systemName: "photo")
            }
            
            Spacer()
            
            Button(action: { focus = nil }) {
                Image(systemName: "keyboard.chevron.compact.down")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
        .padding()
    }
}
