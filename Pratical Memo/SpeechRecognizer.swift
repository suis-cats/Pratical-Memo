import Foundation
import Speech
import AVFoundation
import Combine
import SwiftUI

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var error: String? = nil
    
    private var audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP")) // Default to Japanese
    }
    
    func startTranscribing() {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            self.error = "Speech recognition is not available."
            return
        }
        
        do {
            let (audioEngine, request) = try prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            
            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopTranscribing()
                }
            }
            
            self.isRecording = true
        } catch {
            self.stopTranscribing()
            self.error = "Error starting audio engine: \(error.localizedDescription)"
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        
        isRecording = false
        request = nil
        task = nil
    }
    
    // MARK: - Private Helpers
    
    private func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        // Ensure the audio session is configured properly
        // Note: For macOS (Catalyst) or iOS, session handling might differ slightly.
        // Pure SwiftUI/SwiftData app usually targets iOS/iPadOS.
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle auth status if needed
        }
    }
}
