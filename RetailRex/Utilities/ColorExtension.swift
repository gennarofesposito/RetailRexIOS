import SwiftUI

public extension Color {
    // Brand Palette for National Lottery REX (Retailer Experience)
    static let rexNavy = Color(red: 0.04, green: 0.14, blue: 0.27) // #0B2545
    static let rexRoyal = Color(red: 0.07, green: 0.25, blue: 0.45) // #134074
    static let rexBlue = Color(red: 0.00, green: 0.40, blue: 0.80) // #0066CC
    static let rexGold = Color(red: 1.00, green: 0.78, blue: 0.17) // #FFC72C
    static let rexAmber = Color(red: 0.96, green: 0.62, blue: 0.04) // #F59E0B
    static let rexEmerald = Color(red: 0.06, green: 0.73, blue: 0.51) // #10B981
    static let rexRose = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444
    static let rexCardBg = Color(UIColor.systemBackground)
    static let rexGroupedBg = Color(UIColor.secondarySystemBackground)
}

public struct GlassCardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

public extension View {
    func glassCardStyle() -> some View {
        self.modifier(GlassCardModifier())
    }
}
