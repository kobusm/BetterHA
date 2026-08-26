import Foundation

enum ConnectionTarget: Equatable {
    case local(URL)
    case remote(URL)
}

enum ConnectionResolver {
    static func resolve(
        localURL: URL?,
        remoteURL: URL?,
        timeout: TimeInterval = 3.0,
        probe: (URL, TimeInterval) async -> Bool
    ) async -> ConnectionTarget? {
        if let localURL, await probe(localURL, timeout) {
            return .local(localURL)
        }
        if let remoteURL, await probe(remoteURL, timeout) {
            return .remote(remoteURL)
        }
        return nil
    }
}
