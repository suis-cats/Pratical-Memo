import SwiftUI

enum DetailMode: String, CaseIterable, Identifiable {
    case memo
    case summary
    case playback
    case record
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .memo: return "Memo"
        case .summary: return "Summary"
        case .playback: return "Play"
        case .record: return "Record"
        }
    }
    
    var icon: String {
        switch self {
        case .memo: return "doc.text"
        case .summary: return "text.quote"
        case .playback: return "play.circle"
        case .record: return "mic"
        }
    }
}

struct LiquidGlassTabBar: View {
    @Binding var selection: DetailMode
    @Namespace private var ns
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DetailMode.allCases) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = mode
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 20, weight: selection == mode ? .semibold : .regular))
                            .symbolEffect(.bounce, value: selection == mode)
                        
                        Text(mode.title)
                            .font(.caption2)
                            .fontWeight(selection == mode ? .bold : .medium)
                    }
                    .foregroundColor(selection == mode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background {
                        if selection == mode {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                .matchedGeometryEffect(id: "TabHighlight", in: ns)
                        }
                    }
                }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(height: 68)
        .padding(.horizontal)
    }
}
