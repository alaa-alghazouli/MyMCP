import SwiftUI

/// Badge indicating a server is disabled
struct DisabledBadge: View {
    var body: some View {
        Text("Disabled")
            .font(.caption)
            .foregroundStyle(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(4)
    }
}

#Preview {
    DisabledBadge()
}
