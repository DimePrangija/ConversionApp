import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.04, green: 0.09, blue: 0.26)
    static let cardBackground = Color.white.opacity(0.08)
    static let buttonGradientStart = Color.white
    static let buttonGradientEnd = Color(red: 0.73, green: 0.87, blue: 0.98)
    static let buttonAccent = Color(red: 0.63, green: 0.81, blue: 1.0)
}

struct GradientButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.appBackground)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.buttonGradientStart, .buttonGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .opacity(isEnabled ? 1.0 : 0.55)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: .black.opacity(0.25), radius: configuration.isPressed ? 2 : 6, x: 0, y: configuration.isPressed ? 1 : 4)
    }
}

extension View {
    func appCardStyle() -> some View {
        modifier(AppCardModifier())
    }
}

private struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}
