import SwiftUI

struct UnconfiguredTabView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Tap to configure in Settings")
                .foregroundStyle(.secondary)
        }
    }
}
