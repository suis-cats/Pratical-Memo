import SwiftUI

struct PlaybackView: View {
    let note: Note
    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.3
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Visualizer Mock
            HStack(spacing: 4) {
                ForEach(0..<20) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottom, endPoint: .top))
                        .frame(width: 6, height: CGFloat.random(in: 20...100))
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i)*0.05), value: isPlaying)
                }
            }
            .frame(height: 150)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            
            // Progress
            VStack(spacing: 10) {
                Slider(value: $progress)
                    .tint(.blue)
                HStack {
                    Text("03:12")
                    Spacer()
                    Text("10:00")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
            
            // Controls
            HStack(spacing: 50) {
                Button(action: {}) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                }
                
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 80))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(radius: 10)
                }
                
                Button(action: {}) {
                    Image(systemName: "goforward.15")
                        .font(.title)
                }
            }
            .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
    }
}
