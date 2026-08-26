import SwiftUI

struct ConnectionFailedView: View {
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Can't connect")
                .font(.headline)
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
