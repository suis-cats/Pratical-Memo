//
//  LiquidGlassConfig.swift
//  Pratical Memo
//
//  Created by Suis on 2025/12/06.
//

import SwiftUI

/// A modifier that applies a "Liquid Glass" effect to a view.
/// This simulates the material by using an ultra-thin material background,
/// a subtle white border for specular highlights, and a soft shadow.
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var depth: CGFloat = 1.0 // 0 to 1 intensity
    
    func body(content: Content) -> some View {
        content
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

/// A modifier that adds a "Liquid" spring drag effect.
struct LiquidDragModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Non-linear "rubber band" resistance
                        let translation = value.translation
                        _ = 100 // unused

                        
                        let width = translation.width
                        let height = translation.height
                        
                        // Apply log resistance
                        let resistedWidth = width > 0 ? log10(width / 20 + 1) * 20 : -log10(-width / 20 + 1) * 20
                        let resistedHeight = height > 0 ? log10(height / 20 + 1) * 20 : -log10(-height / 20 + 1) * 20
                        
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                            offset = CGSize(width: resistedWidth, height: resistedHeight)
                        }
                    }
                    .onEnded { _ in
                        // Snap back with liquid bounce
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                            offset = .zero
                        }
                    }
            )
    }
}

extension View {
    /// Applies a simulated Liquid Glass effect.
    func liquidGlass(cornerRadius: CGFloat = 16, depth: CGFloat = 1.0) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, depth: depth))
    }
    
    /// Applies a liquid drag gesture that creates a rubber-band effect.
    func liquidDrag() -> some View {
        self.modifier(LiquidDragModifier())
    }
    
    /// A convenient prominent glass button style
    func glassProminent() -> some View {
        self
            .padding()
            .liquidGlass(cornerRadius: 12, depth: 1.2)
    }
}

// Color extension for glass-friendly colors
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
}
