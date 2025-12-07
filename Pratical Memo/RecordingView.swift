import SwiftUI
import Combine

struct RecordingView: View {
    @Bindable var note: Note
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var duration: TimeInterval = 0
    @State private var isProcessing = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            // Timer Display
            Text(timeString(from: duration))
                .font(.system(size: 60, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.default, value: duration)
            
            if isProcessing {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Analysing Audio...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 50)
            } else {
                Text(audioRecorder.isRecording ? "Recording..." : "Ready to Record")
                    .font(.headline)
                    .foregroundStyle(audioRecorder.isRecording ? .red : .secondary)
                    .padding(.bottom, 50)
            }
            
            // Record Button
            Button(action: {
                withAnimation(.spring()) {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                        duration = 0
                        processRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(audioRecorder.isRecording ? .red.opacity(0.3) : .primary.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    if audioRecorder.isRecording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red)
                            .frame(width: 40, height: 40)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 80, height: 80)
                    }
                }
                .overlay {
                    if audioRecorder.isRecording {
                        Circle()
                            .stroke(.red, lineWidth: 2)
                            .scaleEffect(1.5)
                            .opacity(0)
                            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: audioRecorder.isRecording)
                    }
                }
            }
            .disabled(isProcessing)
            
            Spacer()
            
            // Interaction hint
            if !audioRecorder.isRecording && !audioRecorder.recordings.isEmpty {
                Text(isProcessing ? "Generating Summary..." : "Last recording saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
        }
        .onReceive(timer) { _ in
            if audioRecorder.isRecording {
                duration += 1
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func processRecording() {
        isProcessing = true
        
        // Mock Transcription & Summarization Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                // Mock Transcription
                let transcription = "\n\n[Transcript \(Date().formatted(date: .omitted, time: .shortened))]\nこれは会議のテスト録音です。本日の議題は、Liquid Glassデザインの採用と、AI機能の統合についてです。参加者は全員賛成しています。\n"
                note.content += transcription
                
                // Mock Summary
                let summary = "【要約】\n・Liquid Glassデザインの採用が決定。\n・AI機能（チャット、文字起こし、要約）の統合が進行中。\n・参加者は全員合意。"
                note.summary = summary
                
                isProcessing = false
            }
        }
    }
}
