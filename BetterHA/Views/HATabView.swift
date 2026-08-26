import SwiftUI

enum ConnectionState: Equatable {
    case idle
    case resolving
    case resolved(URL)
    case failed
}

struct HATabView: View {
    let config: TabConfig

    @State private var state: ConnectionState = .idle

    var body: some View {
        Group {
            switch state {
            case .idle, .resolving:
                ProgressView()
            case .resolved(let url):
                WebView(url: url)
            case .failed:
                ConnectionFailedView(retry: resolve)
            }
        }
        .task(id: config) {
            await resolveAsync()
        }
    }

    private func resolve() {
        Task {
            await resolveAsync()
        }
    }

    private func resolveAsync() async {
        state = .resolving
        let target = await ConnectionResolver.resolve(
            localURL: config.localURL,
            remoteURL: config.remoteURL,
            probe: ConnectionProbe.probe
        )
        switch target {
        case .local(let url), .remote(let url):
            state = .resolved(url)
        case nil:
            state = .failed
        }
    }
}
