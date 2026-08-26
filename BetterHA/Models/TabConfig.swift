import Foundation

struct TabConfig: Codable, Identifiable, Equatable {
    let id: Int
    var name: String
    var localAddress: String
    var remoteAddress: String

    init(id: Int, name: String = "", localAddress: String = "", remoteAddress: String = "") {
        self.id = id
        self.name = name
        self.localAddress = localAddress
        self.remoteAddress = remoteAddress
    }

    var isConfigured: Bool {
        localURL != nil || remoteURL != nil
    }

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Tab \(id + 1)" : trimmed
    }

    var localURL: URL? {
        HAURLFormatter.format(localAddress).flatMap { URL(string: $0) }
    }

    var remoteURL: URL? {
        HAURLFormatter.format(remoteAddress).flatMap { URL(string: $0) }
    }
}
