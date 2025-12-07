import SwiftUI

extension Color {
    static let glassBackground: Color = {
        #if os(iOS)
        return Color(uiColor: .systemGroupedBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }()
    
    static let glassText = Color.primary
    
    static let glassSecondaryBackground: Color = {
        #if os(iOS)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #elseif os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color.white
        #endif
    }()
}
