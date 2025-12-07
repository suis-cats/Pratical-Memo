import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "Hello! I can help you with your note. Ask me anything about it.", isUser: false)
    ]
    @State private var inputText: String = ""
    @State private var isThinking: Bool = false
    @FocusState private var isInputFocused: Bool
    
    let noteContent: String // Context for the AI
    var initialQuery: String? = nil
    
    @ObservedObject private var aiService = AIService.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Liquid Glass Style)
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    
                    Text("AI Assistant")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Clear Chat
                    Button(action: {
                        messages = []
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.black.opacity(0.1)),
                    alignment: .bottom
                )
                
                // Chat List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isThinking {
                                HStack {
                                    ProgressView()
                                        .padding(10)
                                        .background(.ultraThinMaterial, in: Circle())
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .transition(.opacity)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages) { _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area (Liquid Glass)
                VStack {
                    HStack(alignment: .bottom, spacing: 10) {
                        TextField("Ask about this note...", text: $inputText, axis: .vertical)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .focused($isInputFocused)
                            .lineLimit(1...5)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 32))
                                .foregroundColor(inputText.isEmpty ? .gray : .blue)
                        }
                        .disabled(inputText.isEmpty || isThinking)
                    }
                    .padding()
                }
                .background(.ultraThinMaterial)
            }
        }
        .onAppear {
            isInputFocused = true
            if let query = initialQuery, !query.isEmpty {
                inputText = query
                sendMessage()
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMsg = ChatMessage(content: inputText, isUser: true)
        messages.append(userMsg)
        
        let query = inputText
        inputText = ""
        isThinking = true
        
        Task {
            do {
                let response = try await aiService.sendMessage(query, context: noteContent)
                let aiMsg = ChatMessage(content: response, isUser: false)
                withAnimation {
                    messages.append(aiMsg)
                    isThinking = false
                }
            } catch {
                let errorMsg = ChatMessage(content: "Sorry, I encountered an error.", isUser: false)
                messages.append(errorMsg)
                isThinking = false
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(14)
                    .background(Color.blue.gradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .blue.opacity(0.1), radius: 2, x: 0, y: 1)
            } else {
                Text(message.content)
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}
