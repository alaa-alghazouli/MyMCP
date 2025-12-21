import SwiftUI

// MARK: - Common View Modifiers

extension View {
    /// Standard card styling with padding, background, and rounded corners
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
    }

    /// Badge styling for small labels and counts
    func badgeStyle() -> some View {
        self
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(4)
    }

    /// Section container styling
    func sectionStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
    }
}
