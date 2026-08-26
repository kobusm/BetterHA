import SwiftUI

struct TabConfigEditorView: View {
    @EnvironmentObject private var store: TabConfigStore
    @State private var config: TabConfig

    init(config: TabConfig) {
        _config = State(initialValue: config)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Tab \(config.id + 1)", text: $config.name)
            }

            Section {
                TextField("192.168.1.10", text: $config.localAddress)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if let formatted = HAURLFormatter.format(config.localAddress) {
                    Text(formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Local Address")
            }

            Section {
                TextField("myhome.duckdns.org", text: $config.remoteAddress)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if let formatted = HAURLFormatter.format(config.remoteAddress) {
                    Text(formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Remote Address")
            } footer: {
                Text("Optional. Used when the local address isn't reachable.")
            }
        }
        .navigationTitle(config.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: config) { _, newValue in
            store.update(newValue)
        }
    }
}
