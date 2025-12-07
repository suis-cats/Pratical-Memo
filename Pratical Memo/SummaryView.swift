import SwiftUI

struct SummaryView: View {
    let note: Note
    @ObservedObject private var aiService = AIService.shared
    @State private var summary: String = "Generating summary..."
    @State private var isLoading: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Analyzing Content...")
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        Spacer()
                    }
                    .padding(.top, 40)
                } else {
                    Text("AI Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(summary)
                        .font(.body)
                        .lineSpacing(6)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    Text("Key Points")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        PointView(text: "Discussed UI/UX improvements")
                        PointView(text: "Liquid Glass aesthetic agreed upon")
                        PointView(text: "Next steps: Recording implementation")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
        .onAppear {
            generateSummary()
        }
    }
    
    private func generateSummary() {
        Task {
            // Simulate AI delay
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                summary = "This note focuses on the development of the 'Pratical Memo' application. Key topics include the integration of AI chat features using mock APIs, implementing a voice recording and transcription system, and refining the 'Liquid Glass' user interface design."
                isLoading = false
            }
        }
    }
}

struct PointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
                .padding(.top, 4)
            Text(text)
        }
    }
}
