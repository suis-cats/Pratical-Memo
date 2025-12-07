import Foundation
import Combine

class AIService: ObservableObject {
    static let shared = AIService()
    
    @Published var isProcessing = false
    
    // Valid mock responses to simulate AI behavior
    private let mockResponses = [
        "This note appears to be about a meeting layout. Have you considered adding a whiteboard for better visualization?",
        "I can help you summarize this. It looks like a brainstorming session.",
        "That's an interesting point. Would you like me to expand on the 'Liquid Glass' concept?",
        "I've analyzed the text. It seems focused on UI/UX design principles.",
        "Recorded. I'll remind you about this deadline tomorrow."
    ]
    
    func sendMessage(_ text: String, context: String) async throws -> String {
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        DispatchQueue.main.async {
            self.isProcessing = false
        }
        
        // Return a mock response based on input length to vary it slightly
        if text.lowercased().contains("summarize") {
            return "Here is a summary of your note: \n\nThe user is focusing on implementing a high-quality iOS app with advanced features like AI chat, voice recording, and specific design aesthetics (Liquid Glass)."
        }
        
        return mockResponses.randomElement() ?? "I didn't quite catch that."
    }
}
